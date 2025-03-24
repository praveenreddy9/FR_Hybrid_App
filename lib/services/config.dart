const BASE_URL = 'https://dealerportal.mllqa.com/api/'; //QA
// const BASE_URL = 'https://logifreightapp.mahindralogistics.com/api/'; //PROD

const IOS_APP_LINK = "https://apps.apple.com/us/app/logi-freight/id6738300117";
const ANDROID_APP_LINK =
    "https://play.google.com/store/apps/details?id=com.mahindralogistics.mpodd_pro";

const IOS_APP_VERSION = '4.10';
const ANDROID_APP_VERSION = '4.10'; //current 4.9
//IsForceUpdate 0 don't show,1 for both,2 for Android,3 for iOS

// const API_LOGIN = "login/authenticateUsers";
const POST_LOGIN_DETAILS = "login/userType";
const API_LOGOUT = "login/logout";
const APP_UPDATE_CHECK = "UpdateAPK/GetUpdateAPKData";

const POST_DRIVER_OTP = "login/validateOTP";
const GET_USER_DETAILS = "login/getUserDetails";
const VALIDATE_LOGIN_USER = "login/validateUser?userName="; //old

const VALIDATE_LOGIN_USER_SSO = "login/validateUserFromSSO"; //login screen
const AUTHENTICATE_LOGIN_USER_SSO =
    "login/authenticateUsersFromSSO"; //password screen

const SIGNUP_USER = "register/createUser";

const GET_DASHBOARD_COUNTS = "dashboard/getTripsReport"; //Dashboard count
const DASHBOARD_SEARCH = "dashboard/search"; //Dashboard search

const GET_USER_CURRENT_LOCATION =
    "trip/getCurrentLocation?tripId="; //current location MAPS
const GET_USER_LOCATIONS_LIST =
    "trip/getLocationDetails"; //array of locations MAPS

const GET_CUSTOMERS_LIST_BY_SEARCH =
    "indent/getCustomerBySearch"; //Indent-Customer list
const GET_CONSIGNOR_LIST_BY_SEARCH =
    "indent/getConsignorBySearch"; //Indent-Consignor list
const GET_CONSIGNEE_LIST_BY_SEARCH =
    "indent/getConsigneeBySearch"; //Indent-Consignee list
const GET_SERVICES_LIST = "indent/getServices"; //Indent-Services list
const GET_VEHICLE_TYPES_LIST =
    "/indent/getVehicleTypes"; //Indent-Vehicle Types list
const GET_PRODUCT_LIST_BY_SEARCH =
    "indent/getProductListBySearch"; //Indent-Product list
const CREATE_INDENT = "indent/create"; //create

const GET_ALL_INDENTS = "indent/getAll"; //indent list
const GET_ALL_SAVED_INDENTS =
    "indent/getAllSavedIndents"; //indent list for supllier

const GET_INDENT_DETAILS_BY_ID =
    "indent/getById?indentId="; //indent details by id
const GET_INDENT_DETAILS_BY_ID_FOR_SUPPLIER =
    "indent/getPickupItemById?indentId="; //indent details by id

const GET_INDENT_LR_DETAILS_BY_ID =
    "indent/getIndentLrDetails?indentId="; //indent details by id after submit

const DELETE_INDENT_BY_ID = "/indent/deleteById?indentId="; //indent delete
const UPDATE_INDENT = "/indent/update"; //indent update

const SAVE_PRIMARY_INDENT_DETAILS =
    "/indent/save"; //indent primary details for save/update
const SAVE_SEONDARY_INDENT_DETAILS =
    "/indent/saveIndentDetails"; //indent secondary details for save/update
const SUBMIT_INDENT =
    "/indent/createTrip"; //submit api to create with logifreight

const DELETE_INDENT_ITEM_BY_ID =
    "indent/deletePickupItemById?indentId="; //indent item delete (consignor,consignee,products,etc) //second screen

//vehicle-driver mapping
const GET_DRIVERS_LIST = "/trip/getDrivers?driver="; //drivers list
const GET_VEHICLES_LIST = "/trip/getVehicles?vehicleNo="; //vehicles list
const GET_GPS_DEVICES_LIST =
    "/trip/getGpsDevices?deviceName="; //GPS Devices list

//trips list screen based on status
const GET_PENDING_ASSIGNMENT_LIST =
    "/dashboard/getNoVehiclePlacedList"; //pending assignment
const GET_READY_TO_PICKUP_LIST =
    "/dashboard/getReadyToPickUpList"; //ready to pickup
const GET_INTRANSIT_LIST = "dashboard/getDispatchedList"; //dispatched
const GET_DELIVERED_LIST = "/dashboard/getDeliveredList"; //delivered

const ALLOCATE_DRIVER_VEHICLE_IN_TRIP =
    "/trip/updateTripDetails"; //allocate D,V

const GET_INVOICE_DETAILS =
    "trip/getInvoiceDetails?ewayBillNumber="; //driver flow get invoice
const SAVE_INVOICE_DETAILS = "trip/updateInvoiceDetails";

const DOWNLOAD_DRIVER_INVOICE_PDF = "trip/downloadInvoice?tripId=";
const EPOD_DOWNLOAD_API = "dashboard/getDownloadUrl?lrNumber=";

const GET_DRIVER_TRIP_DETAILS = "trip/getTripDetails";
const POST_DRIVER_EVENTS = "trip/markDriverEvents";

const DOWNTIME_CHECK = "/user/downtime";

const DEALER_BOOKED_API = "dashboard/getCreatedLrList";
const DEALER_INTRANSIT_API = "dashboard/getIntransitLrList";
const DEALER_DELIVERD_API = "dashboard/getDeliveredLrList";
const DEALER_PENDING_PDI_API = "dashboard/getPendingPdiLrList";
const DEALER_RECORD_DELIVERY_API = "lr/searchEPODWithLR";
const DEALER_DEFECT_TYPE_API = "trip/getDefectTypes";
const DEALER_EPOD_DETAILS_API = "TransactionMaster/GetPrintLRDetails";
const DEALER_EPOD_UPDATE_API = "lr/UpdatePDIDetails";
const DEALER_EPOD_IMAGE_API = "lr/getLRDetails";
const DEALER_EPOD_SIGNATURE_API = "lr/uploadSignature";
const DEALER_EPOD_DEFECT_IMAGE_API = "TransactionMaster/UploadImageLRDefect";
const DEALER_EPOD_CONFIRM_API = "lr/confirmEPOD";
const DEALER_PDF_DOWNLOAD_API = "dashboard/getDownloadUrl?lrNumber=";
const DEALER_SEARCH_PDI_API = "/lr/searchPdiDetails";
