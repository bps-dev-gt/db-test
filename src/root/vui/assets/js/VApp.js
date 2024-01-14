/**
 * @typedef VehicleDetails
 * @type {Object}
 * @property carId {number}
 * @property ccmTech {number}
 * @property constructionType {string}
 * @property constructionType2 {string}
 * @property cylinder {number}
 * @property cylinderCapacityCcm {number}
 * @property cylinderCapacityLiter {number}
 * @property fuelType {string}
 * @property fuelTypeProcess {string}
 * @property impulsionType {string}
 * @property manuId {number}
 * @property manuName {string}
 * @property modId {number}
 * @property modelName {string}
 * @property motorType {string}
 * @property powerHpFrom {number}
 * @property powerHpTo {number}
 * @property powerKwFrom {number}
 * @property powerKwTo {number}
 * @property typeName {string}
 * @property typeNumber {number}
 * @property valves {number}
 * @property yearOfConstrFrom {number}
 * @property yearOfConstrTo {number}
 */

/**
 * @typedef KbaNumber
 * @type {Object}
 * @property kbaNo {string}
 */

/**
 * @typedef KbaNums
 * @type {Object}
 * @property array {KbaNumber[]}
 */

/**
 * @typedef CarInfo
 * @type {Object}
 * @property carId {number}
 * @property kbaNumbers {KbaNums}
 * @property motorCodes {string}
 * @property vehicleDetails {VehicleDetails}
 */

/**
 * Vanilla JS application.
 */
class VApp {

    /**
     * Application identifier.
     * @type {string}
     */
    static label = 'VApp';

    /**
     * Application page identifier.
     * @type {string}
     */
    static pageId = 'v-app';

    /**
     * Application configuration.
     * @type {{urlServer: URL, uriAppRoot: string, uriDataRoot: string}}
     */
    static conf = {
        urlServer: new URL(window.location.origin),
        uriAppRoot: 'vui/',
        uriDataRoot: 'vui/data/'
    };

    /**
     * Temporary data storage.
     * @type {{cars: CarInfo[]}}
     */
    static ds = {
        cars: []
    }

    /**
     * Returns the root URL of the data REST API.
     * @returns {URL} Root URL of the data REST API.
     */
    static get urlDataRoot() {
        let url = VApp.conf.urlServer
        url.pathname = VApp.conf.uriDataRoot;
        return url
    }

    /**
     * Makes an absolute UEL from the given data path.
     * @param subPath {string} Relative path to the data.
     * @returns {URL} URL to the data.
     */
    static makeDataUrl(subPath) {
        let url = VApp.urlDataRoot
        url.pathname = url.pathname + subPath;
        return url;
    }

    /**
     * Makes a GET request to the given data path.
     * @param path {string} Path to the data.
     * @returns {Promise<any>}
     */
    static async doGet(path) {
        let url = VApp.makeDataUrl(path);
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
                // Reject if the server did not return JSON
                // Works only on servers that return content-type header
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

    /**
     * Creates a table cell with the given value.
     * @param value {*}
     * @returns {HTMLTableCellElement}
     */
    static makeTD(value) {
        let td = document.createElement('td')
        td.textContent = value
        return td;
    }

    /**
     * Converts the given kba numbers to a string.
     * @param kbaNums {KbaNums}
     * @returns {string}
     */
    static kbaNumsToString(kbaNums) {
        if (kbaNums.array.length > 0) {
            return kbaNums.array.map((kbaNumber) => kbaNumber.kbaNo).join(',')
        }
        return '';
    }

    /**
     * Creates a table row for the given vehicle and kba numbers.
     * @param vehicle {VehicleDetails}
     * @param kbaNums {KbaNums}
     * @returns {HTMLTableRowElement}
     */
    static makeTR(vehicle, kbaNums) {
        let row = document.createElement('tr');
        row.appendChild(VApp.makeTD(vehicle.carId));
        row.appendChild(VApp.makeTD(VApp.kbaNumsToString(kbaNums)));
        row.appendChild(VApp.makeTD(vehicle.ccmTech));
        row.appendChild(VApp.makeTD(vehicle.constructionType));
        row.appendChild(VApp.makeTD(vehicle.constructionType2));
        row.appendChild(VApp.makeTD(vehicle.cylinder));
        row.appendChild(VApp.makeTD(vehicle.cylinderCapacityCcm));
        row.appendChild(VApp.makeTD(vehicle.cylinderCapacityLiter));
        row.appendChild(VApp.makeTD(vehicle.fuelType));
        row.appendChild(VApp.makeTD(vehicle.fuelTypeProcess));
        row.appendChild(VApp.makeTD(vehicle.impulsionType));
        row.appendChild(VApp.makeTD(vehicle.manuId));
        row.appendChild(VApp.makeTD(vehicle.manuName));
        row.appendChild(VApp.makeTD(vehicle.modId));
        row.appendChild(VApp.makeTD(vehicle.modelName));
        row.appendChild(VApp.makeTD(vehicle.motorType));
        row.appendChild(VApp.makeTD(vehicle.powerHpFrom));
        row.appendChild(VApp.makeTD(vehicle.powerHpTo));
        row.appendChild(VApp.makeTD(vehicle.powerKwFrom));
        row.appendChild(VApp.makeTD(vehicle.powerKwTo));
        row.appendChild(VApp.makeTD(vehicle.typeName));
        row.appendChild(VApp.makeTD(vehicle.typeNumber));
        row.appendChild(VApp.makeTD(vehicle.valves));
        row.appendChild(VApp.makeTD(vehicle.yearOfConstrFrom));
        row.appendChild(VApp.makeTD(vehicle.yearOfConstrTo));
        return row;
    }

    /**
     * Displays the data.
     */
    static showData() {
        let tbl = document.getElementById('carsDataTableBody');
        tbl.innerHTML = null;
        if (VApp.ds.cars.length > 0) {
            document.getElementById('statusMessage').textContent = `Items loaded: ${VApp.ds.cars.length}`;
            VApp.ds.cars.forEach((car) => {
                tbl.appendChild(VApp.makeTR(car.vehicleDetails, car.kbaNumbers));
            })
        } else {
            document.getElementById('statusMessage').textContent = 'No data to display.';
        }
    }

    /**
     * Loads initial components
     * @returns {Promise<Awaited<boolean>|boolean>}
     */
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

    /**
     * Hooks functionality to the page.
     */
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