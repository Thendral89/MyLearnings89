// This module maintains shared state across LWC components
let sharedData = {
    counter: 0,
    userName: 'Guest',
    someFlag: false,
    instanceId: "someInstanceId"
};

export function getSharedData() {
    return sharedData;
}

export function updateSharedData(newData) {
    Object.assign(sharedData, newData);
}