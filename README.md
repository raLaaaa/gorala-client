## gorala-app

This is the corrosponding frontend for a task / calendar app.
It is purely written in Dart + Flutter and is also supported as web version.
BloC is used as state management library.

Originally this project was supposed as a test for Flutters web support.

The app is an infinity calendar scrollwer and allows you to create notes / tasks and add a timestamp to them.
You can take a look at the screenshots below to get a better understanding:

--- images

The frontend covers basic CRUD operations for tasks.
Tasks can be marked as done as well as carry on tasks which means they will pop on each day of the calendar until you have finished them.

--- images

The backend is written in Go and uses [Echo](https://echo.labstack.com/) + [GORM](https://gorm.io/). The flutter app uses the API of this project.
Authentication is done with `JWT`. You can find the backend [here](https://github.com/raLaaaa/gorala-backend).

This is a pure work in progress side time project and has only educational purpose. 
The project is not finished. It is supposed to serve as an starting point for Flutter development and show how Flutter works for web and mobile with one code base.

## Licenses
This library and its content is released under the [MIT License](https://choosealicense.com/licenses/mit/).
