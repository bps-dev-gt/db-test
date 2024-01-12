class VApp {

    static label = 'VApp';
    static pageId = 'v-app';

    static conf = {
        urlServer: new URL(window.location.origin),
        uriAppRoot: 'vui/',
        uriDataRoot: 'vui/data/'
    };

    static ds = {
        cars: []
    }

    static get urlRoot() {
        let url = VApp.conf.urlServer
        url.pathname = VApp.conf.uriDataRoot;
        return url
    }

    static makeUrl(subPath) {
        let url = VApp.urlRoot
        url.pathname = url.pathname + subPath;
        return url;
    }

    static async doGet(path) {
        let url = VApp.makeUrl(path);
        return await fetch(url, {
            "credentials": 'include',
            "method": "GET",
            "headers": {
                "Accept": "application/json"
            }
        }).then(async (response) => {
            if (!response.ok) {
                // Cancel if the request did not succeed.
                return Promise.reject(new Error('Server did not return OK status code.'));
            }
            if (!(response.headers.get('content-type')?.includes('application/json'))) {
                // Reject if the server did not return JSON.
                return Promise.reject(new Error('Invalid content-type returned from server. application/json required.'));
            }
            const data = await response.json() || null;
            if (data) {
                return Promise.resolve(data);
            }
            return Promise.reject(new Error('Unable to retrieve data from server.'));
        }).catch((error) => {
            console.error(error)
            return Promise.reject(error);
        });
    }

    static showData() {
        console.log(VApp.ds.cars);
    }

    static load = async function () {
        if (document.body.id === VApp.pageId) {
            if (VApp.load.done) return Promise.resolve(true);
            VApp.load.done = true;
            return VApp.doGet('js-demo.json').then((ds) => {
                if (ds.status !== 200 || !ds.data || !ds.data.array) {
                    return Promise.reject(new Error('Invalid response.'));
                }
                VApp.ds.cars = ds.data.array;
                return Promise.resolve(true);
            }).catch((err) => {
                return Promise.reject(err)
            })
        }
        return Promise.reject(new Error('Required body not found'));
    }

    static hook() {
        document.addEventListener("DOMContentLoaded", function () {
            VApp.load().then(() => {
                VApp.showData();
                console.info(VApp.label, 'Ready');
            })
        });
    }
}

export default VApp;