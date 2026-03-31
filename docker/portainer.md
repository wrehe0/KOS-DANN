## Portainer

Выполните все этапы работы с проектом по примеру с [Nginx](/content/Docker/ImageLibrary/Nginx.md)

### Вариант с томами (с сохранением данных)

в **Windows Powershell**
```shell
docker run -d `
  --name portainer `
  -p 9000:9000 `
  -p 9443:9443 `
  -v /var/run/docker.sock:/var/run/docker.sock `
  -v portainer_data:/data `
  --restart unless-stopped `
  portainer/portainer-ce:latest
```

![apk update](img/portainer/2026-03-31_10-01-36.png)

[Подключиться через браузер по http://localhost:9000/](http://localhost:9000/)
![aa](img/portainer/2026-03-31_10-04-32.png)

на следующих скриншотах представлены возможности Portainer

![aa](img/portainer/2026-03-31_10-05-31.png)

![aa](img/portainer/2026-03-31_10-05-43.png)

![aa](img/portainer/2026-03-31_10-05-56.png)

![aa](img/portainer/2026-03-31_10-06-19.png)