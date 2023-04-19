# Запуск
```bash
./mvnw compile exec:java -Dexec.mainClass="ru.spbu.detector.DetectorApplicationCli" -Dexec.arguments="path/to/file,n,threshold" -q
```

Аргументы:
1. path/to/file - путь к файлу, формат как в выводе tokenizer.py
2. n - количество слов, которые составляют одну n-грамму
3. threshold - порог для функции isSimilar