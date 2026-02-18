using OrderService as service from '../../srv/order-service';
using from '../../db/schema';

annotate service.Orders with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Value : orderId,
            },
            {
                $Type : 'UI.DataField',
                Value : orderName,
                Label : '{i18n>OrderName}',
            },
            {
                $Type : 'UI.DataField',
                Value : status_code,
                Label : '{i18n>Status}',
            },
            {
                $Type : 'UI.DataField',
                Value : customer_ID,
                Label : '{i18n>CustomerId}',
            },
            {
                $Type : 'UI.DataField',
                Value : customer.name,
                Label : '{i18n>CustomerName}',
            },
        ],
    },
    UI.FieldGroup #Shipment : {
        Data : [
            {
                $Type : 'UI.DataField',
                Value : shipment.order.shipment.shipmentId,
                Label : '{i18n>ShipmentId}',
            },
            {
                $Type : 'UI.DataField',
                Value : shipment.order.shipment.carrier,
                Label : '{i18n>Carrier}',
            },
            {
                $Type : 'UI.DataField',
                Value : shipment.order.shipment.estimatedDelivery,
                Label : 'estimatedDelivery',
            },
            {
                $Type : 'UI.DataField',
                Value : shipment.order.shipment.trackingNo,
                Label : 'trackingNo',
            },
        ]
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneratedFacet1',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneratedGroup',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Order Items',
            Target : 'items/@UI.LineItem'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Shipment',
            Target : '@UI.FieldGroup#Shipment'
        }
    ],
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : '{i18n>OrderId}',
            Value : orderId,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>OrderName}',
            Value : orderName,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>OrderDate}',
            Value : orderDate,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>TotalAmount}',
            Value : totalAmount,
        },
        {
            $Type : 'UI.DataField',
            Value : status_code,
            Label : '{i18n>Status}',
            Criticality : {
                 Path : 'status/code',
                ValueCriticalityMapping : [
                    { Value : 'CREATED', Criticality : 'Neutral' },   // default / no color
                    { Value : 'SHIPMENT', Criticality : 'Critical' }, // yellow
                    { Value : 'PROCESSING', Criticality : 'Positive' }, // green
                    { Value : 'Delivered', Criticality : 'Negative' }   // red
                ]
            }
        },
        {
            $Type : 'UI.DataField',
            Value : customer_ID,
            Label : 'customer_ID',
        },
        {
            $Type : 'UI.DataField',
            Value : items.product.productId,
            Label : 'productId',
        },
        {
            $Type : 'UI.DataField',
            Value : items.product.name,
            Label : 'name',
        },
    ],
    UI.HeaderInfo: {
        TypeName: 'Order',
        TypeNamePlural: 'Orders',
        Title: { Value: orderId },
        Description: { Value: orderName }
    },
    UI.SelectionFields : [
        orderId,
        status_code,
        customer.customerId,
    ],
);

// annotate service.Orders with {
//     customer @Common.ValueList : {
//         $Type : 'Common.ValueListType',
//         CollectionPath : 'Customers',
//         Parameters : [
//             {
//                 $Type : 'Common.ValueListParameterInOut',
//                 LocalDataProperty : customer_ID,
//                 ValueListProperty : 'ID',
//             },
//             {
//                 $Type : 'Common.ValueListParameterDisplayOnly',
//                 ValueListProperty : 'customerId',
//             },
//             {
//                 $Type : 'Common.ValueListParameterDisplayOnly',
//                 ValueListProperty : 'name',
//             },
//             {
//                 $Type : 'Common.ValueListParameterDisplayOnly',
//                 ValueListProperty : 'email',
//             },
//             {
//                 $Type : 'Common.ValueListParameterDisplayOnly',
//                 ValueListProperty : 'phone',
//             },
//         ],
//     }
// };

annotate service.Orders with {
  customer @Common.ValueList : {
    $Type : 'Common.ValueListType',
    CollectionPath : 'Customers',
    Parameters : [
      {
        $Type : 'Common.ValueListParameterInOut',
        LocalDataProperty : customer_ID,
        ValueListProperty : 'ID'
      },

      {
        $Type : 'Common.ValueListParameterOut',
        LocalDataProperty : customer.customerId,
        ValueListProperty : 'customerId'
      },

  
      {
        $Type : 'Common.ValueListParameterOut',
        LocalDataProperty : customer.name,
        ValueListProperty : 'name'
      }
    ]
  }
};


annotate OrderService.Orders with {
    status @UI.DataField : {
        label : '{i18n>StatusCode}'
    };
    
    status 
        @UI.CriticalityCalculation : {
            Red : { Path : 'status_code', Value : 'Shipment' },
            Green : { Path : 'status_code', Value : 'Confirmed' },
            Critical : { Path : 'status_code', Value : 'Processing' },
            Neutral : { Path : 'status_code', Value : 'Created' }
    };
};


annotate service.Orders with {
    orderId @(
        Common.Label : '{i18n>Orderid}',
        )
};

annotate service.Orders with {
    orderDate @(
        Common.Label : '{i18n>Orderdate}',
        Common.FieldControl : #ReadOnly,
        )
};

annotate service.Customers with {
    customerId @(
        Common.Label : '{i18n>Customerid}',
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'Customers',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : customerId,
                    ValueListProperty : 'customerId',
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'name',
                },
            ],
            Label : 'Customer ID',
        },
        Common.ValueListWithFixedValues : true,
    )
};

annotate service.Orders with {
    totalAmount @(
        Common.FieldControl : #ReadOnly,
    )
};

annotate service.OrderItems with @UI: {
    LineItem: [
        { Value: product_ID, Label: 'Product' },
        { Value: quantity, Label: 'Quantity' },
        {
            $Type : 'UI.DataField',
            Value : unitPrice,
            Label : '{i18n>Price}',
        },
    ],

    Identification: [
        { Value: product_ID },
        { Value: quantity },
        { Value: price }
    ]
};

annotate service.OrderItems with {
    product @(
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'Products',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : product_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'name',
                },
            ],
            Label : 'Products',
        },
        Common.ValueListWithFixedValues : true,
)};

annotate service.Products with {
    ID @Common.Text : productId
};

