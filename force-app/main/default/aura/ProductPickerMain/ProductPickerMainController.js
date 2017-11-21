({
    init : function(component, event, helper) {
        const action = component.get('c.serverInit');
        action.setParams({'opportunityId' : component.get('v.oppId')});
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                const responseModel = response.getReturnValue();
                component.set('v.olis', responseModel.olis);
                component.set('v.pbes', responseModel.pbes);
            }
            else {
                alert('error: ' + response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    saveOlis : function(component, event, helper) {
        const theOlis = component.get('olis');
        debugger;
    }
})
