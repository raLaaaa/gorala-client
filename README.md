## gorala-app

This is the corrosponding frontend for a task / calendar app.
It is purely written in [Dart + Flutter](https://flutter.dev/) and is also supported as web version.
[BloC](https://bloclibrary.dev/#/) is used as state management library.

The app is an infinity horizontal calendar scroller that allows you to create notes / tasks and add a timestamp to them.
You can take a look at the screenshots below to get a better understanding:

![app gorala icu_(iPhone SE) (3)](https://user-images.githubusercontent.com/12799722/223953006-8bc13419-0ec7-465f-8671-64dcb65247d8.png)
![app gorala icu_(iPhone SE)](https://user-images.githubusercontent.com/12799722/223952926-51bfbfa7-3506-4b55-baa1-1e50e5673ed7.png)
![app gorala icu_(iPhone SE) (2)](https://user-images.githubusercontent.com/12799722/223953047-57eea7b4-07ae-455c-a1c2-cf384831a4f3.png)
![app gorala icu_(iPhone SE) (1)](https://user-images.githubusercontent.com/12799722/223953062-7b356c60-3594-473f-b3b5-940760d7b326.png)

The frontend covers basic CRUD operations for tasks.
Tasks can be marked as done as well as carry on tasks which means they will pop on each day of the calendar until you have finished them.

The backend is written in Go and uses [Echo](https://echo.labstack.com/) + [GORM](https://gorm.io/). 
Authentication is done with `JWT`. You can find the backend [here](https://github.com/raLaaaa/gorala-backend).

If you want to get the web version going of this app you can use the `Dockerfile` which will start the Flutter app web version.
Otherwise just clone or download the repository and do it the usual Flutter way.

Make sure that the `.env` file contains the URL of the backend. 
If you run everything locally you could for instance use:

```
SERVER=http://10.0.2.2:8080
SERVER_LOCAL=http://10.0.2.2:8080
``` 

This is a pure work in progress side time project and has only educational purpose. 
The project is not finished and is probably buggy somewhere. 
It is supposed to serve as an starting point for Flutter development and show how Flutter works for web and mobile with one code base and also can provide an example on how to structure a simple Flutter app with statemanagement.


## Licenses

This library and its content is released under the [MIT License](https://choosealicense.com/licenses/mit/).
