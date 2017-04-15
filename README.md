# jobwallet-importer
This importer will be fairly simple as it should just automatically import turtle files that where uploaded with the file-uploader service.

## example docker-compose snippet
```
  importer:
    image: flowofcontrol/jobwallet-importer
    links:
      - db:database
    volumes:
      - ./uploads:/files
```
