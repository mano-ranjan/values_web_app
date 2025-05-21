'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "09d62faeab5b379e2f8320081f6c4b97",
"version.json": "dd6629c65a28dc462af0b2f6ef6bae89",
"index.html": "0337c0f74f0a7625fbadb85bbcc60dc8",
"/": "0337c0f74f0a7625fbadb85bbcc60dc8",
"main.dart.js": "d26e7ebe472b71297c0e70a795df854b",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"favicon.png": "92f6fcdbe5063eb05a61d34fc65066ee",
"icons/Icon-192.png": "ac23dccec7ef72453521f7b4196f8682",
"icons/Icon-maskable-192.png": "ac23dccec7ef72453521f7b4196f8682",
"icons/Icon-maskable-512.png": "ec633b107c4a207e37bb1f882db46a6f",
"icons/Icon-512.png": "ec633b107c4a207e37bb1f882db46a6f",
"manifest.json": "5803a981e1f839c4810d5c1b00dc089d",
"assets/AssetManifest.json": "8017518230f4e5d38f8221ff1b5c0f17",
"assets/NOTICES": "184027eb79a669c6879cedf8388bb925",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "5df3e8d6de7b614d51c8caa0c78bb8dd",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "2b371fd1a4d959535daad10207b2e3bc",
"assets/fonts/MaterialIcons-Regular.otf": "634731a47b63503fbce826c51abdcc44",
"assets/assets/images/staff_venkateswara.jpeg": "fc5cc938f15fa92f947c1a5a82baf3c4",
"assets/assets/images/staff_santhosh.jpeg": "db6166640c99d782f7b88ba328cd25f6",
"assets/assets/images/staff_satish.jpeg": "d075078e9b46f831d97ba8937b759bb5",
"assets/assets/images/gallery_3.png": "2d674f75bdc65fb75e337be4a15ee1cb",
"assets/assets/images/gallery_2.png": "27b08779ab2bd4cad75bf33ce02b6140",
"assets/assets/images/staff_narayana.jpeg": "49470baed2097c9769bca672f17c849c",
"assets/assets/images/staff_ashish.jpeg": "c7b336d84988a5f5691c29c67121eb64",
"assets/assets/images/instagram.png": "59ce37415141ef2ebba7740fc715a9cc",
"assets/assets/images/gallery_1.png": "6884aa3583497a698937ce799ba209b5",
"assets/assets/images/staff_indira.jpeg": "c3383f0f007abd29e1cc28d90e25bec5",
"assets/assets/images/gallery_6.jpeg": "e5d09348545dc20e99193f21baa9ae62",
"assets/assets/images/staff_sandula.jpeg": "3e9144ac942d635f004fbc43fc28e24b",
"assets/assets/images/gallery_4.jpeg": "1465bb4dd4ee7ef1b55c24f87f9ef650",
"assets/assets/images/college.png": "95ac132ff250d7e6f54738d1ea869886",
"assets/assets/images/staff_satyamurthy.jpeg": "6f7bfe4d7f3702d034a79590383e2638",
"assets/assets/images/linkedin.png": "d492efc706db983e74258dbd348f2208",
"assets/assets/images/staff_swaroopa.jpeg": "4d5108c28fc2415847170ed4fc621271",
"assets/assets/images/gallery_5.jpeg": "2703bbc939a0aa0ef26ba6f03d653f98",
"assets/assets/images/staff_durga.jpeg": "64658440a95b4ba93583919479151237",
"assets/assets/images/values_logo.png": "098afc66c9d5af205822aa91b04d025e",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
