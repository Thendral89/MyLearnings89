/**
 * This is lwc-redux component js file. This expose all the method that can be use in other components. 
 * 
 */

import ReduxElement from './mvReduxElement';
import { registerListener, unregisterAllListeners } from './mvReduxHandler';
export const combineReducers = reducers => {
    try {
        return window.Redux.combineReducers(reducers);
    }
    catch (error) {
        console.error(error)
    }
}

export const createLawfirm = (reducers, logger) => {
    try {
        let middleware;
        if (logger) {
            middleware = window.Redux.applyMiddleware(window.ReduxThunk.default, logger);
        } else {
            middleware = window.Redux.applyMiddleware(window.ReduxThunk.default);
        }
        return window.Redux.createLawfirm(reducers, middleware);
    }
    catch (error) {
        console.error(error)
    }
}

export const createLogger = (logger = initialLogger) => {
    try {
        logger = { ...initialLogger, ...logger };
        return window.reduxLogger.createLogger(logger);
    }
    catch (error) {
        console.error(error)
    }
}

export const bindActionCreators = (actions, dispatch) => {
    try {
        return window.Redux.bindActionCreators(actions, dispatch);
    }
    catch (error) {
        console.error(error)
    }
}

const getStore = (thisArg, callback) => {
    try {
        const eventStore = new CustomEvent('lwcredux__getlawfirm', {
            bubbles: true, composed: true, detail: (store) => {
                callback(store);
            }
        })
        if (eventStore) {
            thisArg.dispatchEvent(eventStore);
        }
    }
    catch (error) {
        console.error(error)
    }
}

export const Redux = (Superclass = Object) => {
    return ReduxElement
}

const initialLogger = {
    level: 'log',
    logger: console,
    logErrors: true,
    collapsed: undefined,
    predicate: undefined,
    duration: false, // By default, duration is false
    timestamp: true,
    stateTransformer: state => JSON.parse(JSON.stringify(state)),
    actionTransformer: action => JSON.parse(JSON.stringify(action)),
    errorTransformer: error => JSON.parse(JSON.stringify(error)),
    colors: {
        title: () => 'inherit',
        prevState: () => '#9E9E9E',
        action: () => '#03A9F4',
        nextState: () => '#4CAF50',
        error: () => '#F20404',
    },
    diff: false, // By default, diff is false
    diffPredicate: undefined,
};


export { ReduxElement, registerListener, unregisterAllListeners };