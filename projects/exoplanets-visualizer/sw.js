/* eslint-env serviceworker */

const planet_images = [
    '/images/planets/planet_jovian.png',
    '/images/planets/planet_neptunian.png',
    '/images/planets/planet_superearth.png',
    '/images/planets/planet_terrestrial.png',
    '/images/planets/planet_unknown.png'
]

self.addEventListener("install", (event) => {
    event.waitUntil(
        caches.open("image-cache").then((cache) => {
            return cache.addAll([
                ...planet_images
            ]);
        })
    );
});

self.addEventListener("fetch", (event) => {
    if (event.request.destination === "image") {
        event.respondWith(
            caches.match(event.request).then((response) => {
                return response || fetch(event.request);
            })
        );
    }
});
