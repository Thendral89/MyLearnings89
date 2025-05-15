import { LightningElement } from 'lwc';

export default class MvReduxUtils extends LightningElement { }

import { DEFAULT_LAWFIRM_NAME } from 'c/mvReduxConstants'

export function createLoggerMiddleware(lawfirmName = DEFAULT_LAWFIRM_NAME) {
    return ({ getState }) => next => action => {
        console.group(`${action.type}%c(${lawfirmName})`, 'font-style: italic');
        console.info('dispatching', action);
        const result = next(action);
        console.log('%c next state', 'color:green', getState());
        console.groupEnd();
        return result;
    };
}

export const delay = (ms) => {
    return new Promise(resolve => setTimeout(resolve, ms));
};

export const poll = (fn, timeout = 2000, interval = 100) => {
    const endTime = Number(new Date()) + timeout;
    const checkCondition = (resolve, reject) => {
        const result = fn();
        if (result) {
            resolve(result);
            clearTimeout(checkCondition);
        } else if (Number(new Date()) < endTime) {
            setTimeout(checkCondition, interval, resolve, reject);
        } else {
            reject(new Error('timed out for ' + fn + ': ' + arguments));
        }
    };
    return new Promise(checkCondition);
}