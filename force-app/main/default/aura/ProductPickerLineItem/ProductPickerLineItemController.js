({
    setSelectedProduct : function(component, event, helper) {
        const selectedProductId = component.find('ProductSelection').get('v.value');
        const pbes = component.get('v.pbes');
        let selectedProduct;
        for (let i = 0; i < pbes.length; i++) {
            if (pbes[i].Product2Id === selectedProductId) {
                selectedProduct = pbes[i];
                break;
            }
        }
        const theOli = component.get('v.wrapper');
        theOli.oli.Product2Id = selectedProductId;
        theOli.oli.UnitPrice = selectedProduct.UnitPrice;
        component.set('v.wrapper', theOli);
    },

    stageForDeletion : function(component, event, helper) {
        const theOli = component.get('v.wrapper');
        theOli.deleteFlag = true;
        component.set('v.wrapper', theOli);
    }
})