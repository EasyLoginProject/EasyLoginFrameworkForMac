# EasyLogin framework for Mac

This framework offer two services:
* Cocoa adapters to talk with the server
* XPC Service to manage caching service safely accessible by multiple processes

The sync process between server and local cache isn't handled by this framework but a dedicated app.

This framework must be designed to be usable by admin tools, sync agent, and custom tools that want to consume directory infos.

The local DB provided via the XPC Service will contain all synced records and will be in charge of record lookup based on custom predicates provided by consuming app. At this time, index management might look "unefficient" for some, don't forget that you're more than unlikely to have hundreds of records synced by devices.
