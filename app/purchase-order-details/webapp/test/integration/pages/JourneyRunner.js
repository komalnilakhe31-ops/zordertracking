sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"com/bosch/purchaseorderdetails/test/integration/pages/OrdersList",
	"com/bosch/purchaseorderdetails/test/integration/pages/OrdersObjectPage"
], function (JourneyRunner, OrdersList, OrdersObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('com/bosch/purchaseorderdetails') + '/test/flp.html#app-preview',
        pages: {
			onTheOrdersList: OrdersList,
			onTheOrdersObjectPage: OrdersObjectPage
        },
        async: true
    });

    return runner;
});

