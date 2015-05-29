# There - HERE Playground

Playing around with the Nokia HERE API

## Setup
0. init update submodule `git submodule update --init`
1. Build the project once; `LocalConfig.swift` in the `There` Project is created
2. enter your HERE **app_id** and **app_code** into the LocalConfig
3. run the app

## Known issues
* The API parsing `ThereSDK` is one big hack - don't treat this code serious. There is an SDK available but only for contractors (trials don't count).
* No real consistency checks in the "SDK"

## TODOs
* [ALL] pan/zoom to search results if they aren't on the visible map rect
* [PAD] tour overview as popup instead a new view
* [PHONES] in landscape split view, e.g. left tour, right map
* [ALL] tweak search: by cathegories, suggestions (not allowed for trials?), etc.
* [ALL] persistency and synching => CoreData & iCloud or via HERE API
* [ALL] sharing of tours via HERE API
* [ALL] routing customization: modes of transport, etc., optional routes (API supports that)