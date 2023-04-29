package ru.spbu.detector.controller.filter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.MDC;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.text.MessageFormat;
import java.util.UUID;

@Component
@Order(0)
public class Slf4jMDCFilter extends OncePerRequestFilter {
    private static final String RID = "rid";
    private static final String OP = "op";
    private static final String STATUS = "status";

    protected void doFilterInternal(final HttpServletRequest request, final HttpServletResponse response, FilterChain chain) throws ServletException, IOException {
        try {
            String rid = UUID.randomUUID().toString();
            MDC.put(RID, rid);
            MDC.put(OP, MessageFormat.format("{0} {1}", request.getMethod(), request.getRequestURI()));

            response.addHeader(RID, rid);
            MDC.put(STATUS, String.valueOf(response.getStatus()));

            chain.doFilter(request, response);
        } finally {
            MDC.clear();
        }
    }
}
