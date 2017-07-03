#EasyLogin framwork for Mac

This framework offer two services:
* Cocoa adapters to talk with the server
* XPC Service to manage caching service safely accessible by multiple processes

The sync process between server and local cache isn't handled by this framework but a dedicated app.

This framework must be designed to be usable by admin tools, sync agent, and custom tools that want to consume directory infos.
