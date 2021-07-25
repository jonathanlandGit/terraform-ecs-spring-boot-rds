FROM openjdk:8

EXPOSE 8080
EXPOSE 3306 
VOLUME /tmp
ADD target/app-1.0-SNAPSHOT.jar app.jar
CMD ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]

