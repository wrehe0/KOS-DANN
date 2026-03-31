## База данных Redis


Запуск **Redis**
```shell
docker run -d --name my-redis -p 6379:6379 redis:alpine
```
![alt text](img/redis/2026-03-31_12-21-42.png)

Подключиться к **Redis CLI**
```shell
docker exec -it my-redis redis-cli
```
![alt text](img/redis/2026-03-31_12-22-54.png)

