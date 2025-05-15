const INITIAL_ERROR_STATE = {};

export const error = (state = INITIAL_ERROR_STATE, action) => {
    switch (action.type) {
        case "ADD_ERROR":
            return action.payload;
        default:
            return state;
    }
}