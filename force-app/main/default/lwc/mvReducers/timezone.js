const INITIAL_TIMEZONE = {

}

export const timezone = (state = INITIAL_TIMEZONE, action) => {
    switch (action.type) {
        case "UPDATE_TIMEZONE":
            return {
                ...state,
                content: action.timezone
            }
        default:
            return state;
    }
}