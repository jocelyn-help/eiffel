The following commands assume the database is example@localhost.

1 - Initialize the database:

mt_server -d example -s stop

mt_server -d example init


2 - Load the schema:

mt_sdl -d example import --odl -f examples.odl


3 - Generate the Persistent Classes:

mt_sdl stubgen --lang eiffel -f examples.odl


4 - Compile the Eiffel project

open the sql.ecf file and click compile



For more information on this sample application, see the Matisse Eiffel 
Programmer's Guide.

http://www.matisse.com/developers/documentation/

***
