// const cds = require('@sap/cds');

// module.exports = async function () {

//   const logistics = await cds.connect.to('LogisticsService');

//   this.on('READ', 'Shipments', async req => {
//     const shipmentId = req.data.ShipmentID;

//     const result = await logistics.run(
//       SELECT.from('Shipments').where({ ShipmentID: shipmentId })
//     );

//     return result;
//   });

// };
const cds = require('@sap/cds');
const { SELECT } = cds;

module.exports = cds.service.impl(function () {

  const { Orders } = this.entities;

  this.before('NEW', Orders, async (req) => {

    // If already generated, skip
    if (req.data.orderId) return;

    const tx = cds.tx(req);

    const lastOrder = await tx.run(
      SELECT.one
        .from(Orders)
        .columns('orderId')
        .where({ orderId: { '!=': null } })
        .orderBy({ orderId: 'desc' })
    );

    let next = 1;

    if (lastOrder?.orderId) {
      const num = parseInt(lastOrder.orderId.replace(/\D/g, ''), 10);
      if (!isNaN(num)) next = num + 1;
    }

    req.data.orderId = `ORD-${String(next).padStart(4, '0')}`;
  });
});


module.exports = srv => {

    srv.before('CREATE', 'Orders', async req => {

        const tx = srv.tx(req);

        const result = await tx.run(
            SELECT.one.from('sap.capire.orders.Orders')
                .columns('orderId')
                .orderBy({ orderId: 'desc' })
        );

        let nextNumber = 1;
        if (result?.orderId) {
            nextNumber = parseInt(result.orderId.split('-')[1]) + 1;
        }

        req.data.orderId = `ORD-${String(nextNumber).padStart(4, '0')}`;
    });
};

module.exports = cds.service.impl(async function () {

  const { Orders, OrderItems, Products, Shipments } = this.entities

  /* ---------------------------------------------------------
     BEFORE CREATE – Orders
     - Set default status
     - Calculate totalAmount
  ---------------------------------------------------------- */
  this.before('CREATE', Orders, async (req) => {

    // Default Order Status
    if (!req.data.status_code) {
      req.data.status_code = 'NEW'   // must exist in OrderStatus CodeList
    }

    // Calculate total amount from items
    let total = 0

    if (req.data.items && req.data.items.length) {
      for (const item of req.data.items) {
        total += (item.quantity || 0) * (item.unitPrice || 0)
      }
    }

    req.data.totalAmount = total
  })

  /* ---------------------------------------------------------
     AFTER READ – Orders
     - Just example enrichment
  ---------------------------------------------------------- */
  this.after('READ', Orders, (orders) => {
    if (!Array.isArray(orders)) orders = [orders]

    orders.forEach(order => {
      order.isHighValue = order.totalAmount > 100000
    })
  })

  /* ---------------------------------------------------------
     ACTION – Create Shipment for an Order
  ---------------------------------------------------------- */
  this.on('createShipment', async (req) => {
    const { orderID, carrier } = req.data

    if (!orderID) req.error(400, 'Order ID is required')

    const shipment = await INSERT.into(Shipments).entries({
      carrier,
      status: 'In Transit'
    })

    await UPDATE(Orders)
      .set({ shipment_ID: shipment.ID })
      .where({ ID: orderID })

    return shipment
  })

  /* ---------------------------------------------------------
     VALIDATION – OrderItems
     - Ensure product exists
  ---------------------------------------------------------- */
  this.before('CREATE', OrderItems, async (req) => {
    const product = await SELECT.one.from(Products).where({
      ID: req.data.product_ID
    })

    if (!product) {
      req.error(400, 'Invalid product selected')
    }
  })

})
