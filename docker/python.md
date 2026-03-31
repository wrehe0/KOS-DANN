## Python для запуска скриптов


1. Создайте **Python** скрипт
```shell
echo "print('Hello from Python in Docker!')" > script.py
```
![alt text](img/python/2026-03-31_12-11-17.png)

2. Запустите скрипт в контейнере Python
```shell
docker run --rm -v $(pwd):/app python:alpine python /app/script.py
```
![alt text](img/python/2026-03-31_12-13-24.png)

3. Интерактивный **Python**
```shell
docker run -it --rm python:alpine python
```
![alt text](img/python/2026-03-31_12-13-48.png)
