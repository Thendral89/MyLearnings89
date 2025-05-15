({
    handleLocationChange: function(component, event, helper) {
        var isLwcVisible = component.get("v. isLwcVisible");
        if (isLwcVisible) {
            component.set("v. isLwcVisible", false);
        } else {
            component.set("v. isLwcVisible", true);
        }
    },
})