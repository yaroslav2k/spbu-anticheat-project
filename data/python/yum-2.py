#!/usr/bin/python -t
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
# Copyright 2005 Duke University


import os
import os.path
import sys
import logging
import time
import errno

from yum import Errors
from yum import plugins
from yum import logginglevels
from yum import _
from yum.i18n import utf8_width, exception2msg
import yum.misc
import cli
from utils import suppress_keyboard_interrupt_message


def cprof(func, *args, **kwargs):
    """Profile the given function using the cprof profiler.

    :param func: the function to profile
    :return: the return code given by the cprof profiler
    """
    import cProfile, pstats
    fn = os.path.expanduser("~/yum.prof")
    prof = cProfile.Profile()
    rc = prof.runcall(func, *args, **kwargs)
    prof.dump_stats(fn)
    print_stats(pstats.Stats(fn))
    return rc

def print_stats(stats):
    """Print out information from a :class:`Stats` object.

    :param stats: the :class:`Stats` object to print information from
    """
    stats.strip_dirs()
    stats.sort_stats('time', 'calls')
    stats.print_stats(20)


    stats.sort_stats('cumulative')
    stats.print_stats(40)

suppress_keyboard_interrupt_message()

def main(args):
    """Run the yum program from a command line interface."""

    yum.misc.setup_locale(override_time=True)

    def exUserCancel():
        logger.critical(_('\n\nExiting on user cancel'))
        if unlock(): return 200
        return 1

    def exIOError(e):
        if e.errno == 32:
            logger.critical(_('\n\nExiting on Broken Pipe'))
        else:
            logger.critical(_('\n\n%s') % exception2msg(e))
        if unlock(): return 200
        return 1

    def exPluginExit(e):
        exitmsg = exception2msg(e)
        if exitmsg:
            logger.warn('\n\n%s', exitmsg)
        if unlock(): return 200
        return 1

    def exFatal(e):
        logger.critical('\n\n%s', exception2msg(e.value))
        if unlock(): return 200
        return 1

    def exRepoError(e):
        # For RepoErrors ... help out by forcing new repodata next time.
        # XXX: clean only the repo that has failed?
        try:
            base.cleanExpireCache()
        except Errors.YumBaseError:
            # Let's not confuse the user further (they don't even know we tried
            # the clean).
            pass


        repoui = _('Unknown')
        repoid = _('<repoid>')
        try:
            repoid = e.repo.id
            repoui = e.repo.name
        except AttributeError:
            pass

        msg = msg % {'repoid' : repoid, 'repo' : repoui}

        logger.critical('\n\n%s\n%s', msg, exception2msg(e))

        if unlock(): return 200
        return 1

    def unlock():
        try:
            base.closeRpmDB()
            base.doUnlock()
        except Errors.LockError, e:
            return 200
        return 0

    def rpmdb_warn_checks():
        try:
            probs = base._rpmdb_warn_checks(out=verbose_logger.info, warn=False)
        except Errors.YumBaseError, e:
            # This is mainly for PackageSackError from rpmdb.
            verbose_logger.info(_(" Yum checks failed: %s"), exception2msg(e))
            probs = []

        if not probs:
            verbose_logger.info(_(" You could try running: rpm -Va --nofiles --nodigest"))

    logger = logging.getLogger("yum.main")
    verbose_logger = logging.getLogger("yum.verbose.main")

    # Try to open the current directory to see if we have
    # read and execute access. If not, chdir to /
    try:
        f = open(".")
    except IOError, e:
        if e.errno == errno.EACCES:
            logger.critical(_('No read/execute access in current directory, moving to /'))
            os.chdir("/")
    else:
        f.close()
    try:
        os.getcwd()
    except OSError, e:
        if e.errno == errno.ENOENT:
            logger.critical(_('No getcwd() access in current directory, moving to /'))
            os.chdir("/")

    # our core object for the cli
    base = cli.YumBaseCli()

    try:
        base.waitForLock()
    except Errors.YumBaseError, e:
        return exFatal(e)

    try:
        result, resultmsgs = base.doCommands()
    except plugins.PluginYumExit, e:
        return exPluginExit(e)
    except Errors.RepoError, e:
        return exRepoError(e)
    except Errors.YumBaseError, e:
        result = 1
        resultmsgs = [exception2msg(e)]
    except KeyboardInterrupt:
        return exUserCancel()
    except IOError, e:
        return exIOError(e)

    # Act on the command/shell result
    if result == 0:
        # Normal exit
        for msg in resultmsgs:
            verbose_logger.log(logginglevels.INFO_2, '%s', msg)
        if unlock(): return 200
        return base.exit_code
    elif result == 1:
        # Fatal error
        for msg in resultmsgs:
            logger.critical(_('Error: %s'), msg)
        if unlock(): return 200
        return 1
    elif result == 2:
        # Continue on
        pass
    elif result == 100:
        if unlock(): return 200
        return 100
    else:
        logger.critical(_('Unknown Error(s): Exit Code: %d:'), result)
        for msg in resultmsgs:
            logger.critical(msg)
        if unlock(): return 200
        return 3

    # Mainly for ostree, but might be useful for others.
    if base.conf.usr_w_check:
        usrinstpath = base.conf.installroot + "/usr"
        usrinstpath = usrinstpath.replace('//', '/')
        if (os.path.exists(usrinstpath) and
            not os.access(usrinstpath, os.W_OK)):
            logger.critical(_('No write access to %s directory') % usrinstpath)
            logger.critical(_('  Maybe this is an ostree image?'))
            logger.critical(_('  To disable you can use --setopt=usr_w_check=false'))
            if unlock(): return 200
            return 1

    # Depsolve stage
    verbose_logger.log(logginglevels.INFO_2, _('Resolving Dependencies'))

    try:
        (result, resultmsgs) = base.buildTransaction()
    except plugins.PluginYumExit, e:
        return exPluginExit(e)
    except Errors.RepoError, e:
        return exRepoError(e)
    except Errors.YumBaseError, e:
        result = 1
        resultmsgs = [exception2msg(e)]
    except KeyboardInterrupt:
        return exUserCancel()
    except IOError, e:
        return exIOError(e)

    # Act on the depsolve result
    if result == 0:
        # Normal exit
        if unlock(): return 200
        return base.exit_code
    elif result == 1:
        # Fatal error
        for prefix, msg in base.pretty_output_restring(resultmsgs):
            logger.critical(prefix, msg)
        if base._depsolving_failed:
            if not base.conf.skip_broken:
                verbose_logger.info(_(" You could try using --skip-broken to work around the problem"))
            rpmdb_warn_checks()
        if unlock(): return 200
        return 1
    elif result == 2:
        # Continue on
        pass
    else:
        logger.critical(_('Unknown Error(s): Exit Code: %d:'), result)
        for msg in resultmsgs:
            logger.critical(msg)
        if unlock(): return 200
        return 3

    verbose_logger.log(logginglevels.INFO_2, _('\nDependencies Resolved'))

    # Run the transaction
    try:
        inhibit = {'what' : 'shutdown:idle',
                   'who'  : 'yum cli',
                   'why'  : 'Running transaction', # i18n?
                   'mode' : 'block'}
        return_code = base.doTransaction(inhibit=inhibit)
    except plugins.PluginYumExit, e:
        return exPluginExit(e)
    except Errors.RepoError, e:
        return exRepoError(e)
    except Errors.YumBaseError, e:
        return exFatal(e)
    except KeyboardInterrupt:
        return exUserCancel()
    except IOError, e:
        return exIOError(e)

    # rpm ts.check() failed.
    if type(return_code) == type((0,)) and len(return_code) == 2:
        (result, resultmsgs) = return_code
        for msg in resultmsgs:
            logger.critical("%s", msg)
        rpmdb_warn_checks()
        return_code = result
        if base._ts_save_file:
            verbose_logger.info(_("Your transaction was saved, rerun it with:\n yum load-transaction %s") % base._ts_save_file)
    elif return_code < 0:
        return_code = 1 # Means the pre-transaction checks failed...
        #  This includes:
        # . No packages.
        # . Hitting N at the prompt.
        # . GPG check failures.
        if base._ts_save_file:
            verbose_logger.info(_("Your transaction was saved, rerun it with:\n yum load-transaction %s") % base._ts_save_file)
    else:
        verbose_logger.log(logginglevels.INFO_2, _('Complete!'))

    if unlock(): return 200
    return return_code or base.exit_code

def user_main(args, exit_code=False):
    """Call one of the multiple main() functions based on environment variables.

    :param args: command line arguments passed into yum
    :param exit_code: if *exit_code* is True, this function will exit
       python with its exit code when it has finished executing.
       Otherwise, it will return its exit code.
    :return: the exit code from yum execution
    """
    errcode = None
    if 'YUM_PROF' in os.environ:
        if os.environ['YUM_PROF'] == 'cprof':
            errcode = cprof(main, args)
        if os.environ['YUM_PROF'] == 'hotshot':
            errcode = hotshot(main, args)
    if 'YUM_PDB' in os.environ:
        import pdb
        pdb.run(main(args))

    if errcode is None:
        errcode = main(args)
    if exit_code:
        sys.exit(errcode)
    return errcode

if __name__ == "__main__":
    try:
        user_main(sys.argv[1:], exit_code=True)
    except KeyboardInterrupt, e:
        print >> sys.stderr, _("\n\nExiting on user cancel.")
        sys.exit(1)
