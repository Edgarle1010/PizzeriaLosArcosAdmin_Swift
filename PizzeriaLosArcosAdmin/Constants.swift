//
//  K.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 08/01/22.
//

import Foundation

struct K {
    
    struct URLS {
        static let termsAndConditions = "https://pizzerialosarcos-9c55f.web.app/"
        static let privacyPolicy = "https://pizzerialosarcos-9c55f.web.app/notice_privacy.html"
    }
    
    struct Texts {
        static let termsAndPrivacy = "Si pulsa Aceptar significa que acepta nuestros Términos y condiciones y ha leído el Aviso de privacidad"
        static let termsAndConditions = "Términos y condiciones"
        static let privacyPolicy = "Aviso de privacidad"
        static let delete = "Borrar"
        
        static let problemOcurred = "¡Ha ocurrido un problema!"
        static let suspendedAccount = "Tu cuenta ha sido limitada para hacer pedidos por el uso incorrecto del servicio. Comunicate a soporte si deseas revisar tu caso."
        static let outOfService = "Fuera de servicio"
        
        static let alert = "Alerta"
        static let listEmpty = "La lista está vacía"
        
        static let questionOrder = "¿Seguro que quieres realizar el pedido?"
        static let importantAnnouncement = "¡Aviso importante!"
        static let deleteAccountMessage = "\nTu cuenta será eleminada permanentemente junto con tu información de usuario.\n\nLas ordenes realizadas en esta cuentan seguiran almacenas en nuestros servidores por cuestiones de estadística, así como las incidencias que tuvo la cuenta al hacer uso del servicio.\n\nSi se quisiera crear una cuenta nueva con el número celular actual, será necesario contactar a soporte.\n\nIntroduce tu contraseña actual para continuar"
        
        static let orderSentSuccessfullyTitle = "Pedido enviado correctamente"
        static var orderSuccessfullyMessage = "Tu pedido ya está en proceso, puedes pasar por el en %@ minutos. \nNúmero de folio: %@\n\nRecuerda recogerlo en la pizzería ubicada en el Periférico Gómez Morín"
        
        static let guestMode = "Modo invitado"
        static let guestMessage = "Iniciaras sesión en modo invitado, podrás ver el menú completo y la mayoria de las funciones pero no podrás realizar pedidos hasta realizar el proceso de registro."
        static let guestFunctionsMessage = "Al estar en modo invitado no tienes acceso a esta función. Inicia sesión o registrate para continuar."
        static let goBack = "Volver"
        static let ok = "OK"
        static let cancel = "Cancelar"
        
        static let locationNotProveided = "Ubicación no proporcionada"
        
        static let FOOD_TYPE = "FOOD_TYPE"
        static let FOOD_TITLE = "FOOD_TITLE"
        static let FOOD_ITEM = "FOOD_ITEM"
        static let FOOD_SIZE = "FOOD_SIZE"
        
        static let PIZZA = "pizza"
        static let PIZZA_TITLE = "Pizzas"
        static let PIZZA_SUBTITLE = "Pizza "
        static let BURGER = "burger"
        static let BURGER_TITLE = "Hamburguesas"
        static let SALAD = "salad"
        static let SALAD_TITLE = "Ensaladas"
        static let PLATILLO = "platillo"
        static let PLATILLO_TITLE = "Platillos"
        static let SEA_FOOD = "seaFood"
        static let SEA_FOOD_TITLE = "Mariscos"
        static let BREAKFAST = "breakfast"
        static let BREAKFAST_TITLE = "Desayunos"
        static let DRINKS = "drinks"
        static let DRINKS_TITLE = "Bebidas"
        static let DESSERTS = "desserts"
        static let DESSERTS_TITLE = "Postres"
        static let MILKSHAKESICECREAM = "milkshakesIceCream"
        static let MILKSHAKESICECREAM_TITLE = "Nieves y malteadas"
        static let KIDS = "kids"
        static let KIDS_TITLE = "Kids"

        static let HOTDOG_ID = "burgerHotDog"
        static let HOTDOG_FOOD_TYPE = "hotdog"
        static let FRENCH_FRIES_ID = "burgerPapasFrancesa"
        static let SPAGHETTI_ID = "platilloSpaghetti"
        static let SPAGHETTI_FOOD_TYPE = "spaghetti"
        static let TORTILLA_SOUP_ID = "platilloSopaTortilla"
        static let TORTILLA_SOUP_FOOD_TYPE = "tortillaSoup"
        static let ENCHILADAS_ID = "Enchiladas"
        static let ENCHILADAS_FOOD_TYPE = "enchiladas"
        static let SHRIMP_ID = "seaFoodCoctelCamarones"
        static let SHRIMP_FOOD_TYPE = "seaFood"
        static let FISH_STEAK_ID = "seaFoodFileteEmpanizado"
        static let FISH_STEAK_TITLE = "Filete"
        static let FISH_STEAK_FOOD_TYPE = "fishSteak"
        static let RANCH_SHRIMP_ID = "seaFoodCamaronesRancheros"
        static let RANCH_SHRIMP_FOOD_TYPE = "ranchShrimp"
        static let EGGS_INGREDIENTS_ID = "ingredientB"
        static let SODA_ID = "drinksRefresco"
        static let SODA_FOOD_TYPE = "soda"
        static let FUZETEA_ID = "drinksFuzeTea"
        static let FUZETEA_FOOD_TYPE = "fuzeTea"
        static let SMOOTHIE_ID = "drinksLicuado"
        static let SMOOTHIE_FOOD_TYPE = "smoothie"
        static let ICECREAM_ID = "iceCream"
        static let ICECREAM_FOOD_TYPE = "iceCream"
        static let MILKSHAKE_ID = "milkshakesIceCreamMalteada"
        static let MILKSHAKE_FOOD_TYPE = "milkShake"
        static let ICECREAM_FOOD_ID = "milkshakesIceCreamNieve" 
    }
    
    struct UserDef {
        static let name = "name"
        static let lastName = "lastName"
        static let email = "email"
        static let authVerificationID = "authVerificationID"
        static let phoneNumber = "phoneNumber"
        static let isRecoveryProcess = "isRecoveryProcess"
    }
    
    struct BrandColors {
        static let primaryColor = "primaryColor"
        static let secundaryColor = "secundaryColor"
        static let thirdColor = "thirdColor"
        static let quarterColor = "quarterColor"
    }
    
    struct Images {
        static let cancel = "cancel"
        static let add = "add"
        static let delete = "delete"
        static let back = "back"
        static let print = "print"
        static let more = "more"
        static let historyIcon = "history_icon"
        static let faul = "faul"
        static let ban = "ban"
        static let check = "check"
    }
    
    struct Firebase {
        static let userCollection = "Users"
        static let phoneNumberField = "phoneNumber"
        static let emailField = "email"
        static let nameField = "name"
        static let lastNameField = "lastName"
        static let baned = "isBaned"
        static let fcmToken = "fcmToken"
        static let streaks = "streaks"
        static let isBaned = "isBaned"
        
        static let foodCollection = "Food"
        static let extraIngredientsCollection = "ExtraIngredients"
        static let id = "id"
        static let listPosition = "listPosition"
        
        static let waitTimeCollection = "waitTime"
        static let time = "time"
        
        static let messageCollection = "messages"
        static let current = "current"
        static let message = "message"
        static let status = "status"
        static let options = "options"
        static let posts = "posts"
        
        static let ordersCollection = "orders"
        static let folio = "folio"
        static let client = "client"
        static let state = "status"
        static let complete = "complete"
        static let dateProcessed = "dateProcessed"
        static let dateFinished = "dateFinished"
        static let dateDelivered = "dateDelivered"
        static let dateCanceled = "dateCanceled"
        
        static let notificationsCollection = "notifications"
        static let userToken = "userToken"
        
    }
    
    struct Regions {
        var description: String
        var prefix: String
    }
    
    static let regions = [Regions(description: "🇲🇽 México (+52)", prefix: "+52"), Regions(description: "🇺🇸 Estados Unidos (+1)", prefix: "+1")]
    
    static let amountArray = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    
    struct Segues {
        static let loginToMenu = "LoginToMenu"
        static let loginToVerificationCode = "LoginToVerificationCode"
        static let guestToMenu = "GuestToMenu"
        static let userInformationToPhoneNumber = "UserInformationToPhoneNumber"
        static let phoneNumberToVerificationCode = "PhoneNumberToVerificationCode"
        static let verificationCodeToCreatePassword = "VerificationCodeToCreatePassword"
        static let createPasswordToMenu = "CreatePasswordToMenu"
        static let menuToFoodList = "MenuToFoodList"
        static let foodListToOrderDetails = "FoodListToOrderDetails"
        static let orderDetailsToHalfFood = "OrderDetailsToHalfFood"
        static let orderDetailsToExtraIngredient = "OrderDetailsToExtraIngredient"
        static let orderDetailsToAmount = "OrderDetailsToAmount"
        static let moreToUserInformation = "MoreToUserInformation"
        static let moreToAbout = "MoreToAbout"
        static let userInformationToEditUserName = "UserInformationToEditUserName"
        static let userInformationToChangePassword = "UserInformationToChangePassword"
        
        static let inProccessToOrderDetails = "InProccessToOrderDetails"
        static let orderDetailsToUbicationMap = "OrderDetailsToUbicationMap"
        static let InProccessToServiceMessage = "InProccessToServiceMessage"
        static let clientDetailsToOrdersHistory = "ClientDetailsToOrdersHistory"
        static let ordersHistoryToOrderDetails = "OrdersHistoryToOrderDetails"
        static let fullOrdersHistoryToOrderDetails = "FullOrdersHistoryToOrderDetails"
    }
    
    struct ViewControllers {
        static let inProcessViewController = "InProcessViewController"
        static let menuViewController = "MenuViewController"
        static let shoppingCarViewController = "ShoppingCarViewController"
        static let moreViewController = "MoreViewController"
        static let clientsTableViewController = "ClientsTableViewController"
        static let clientDetailsViewController = "ClientDetailsViewController"
        static let splitViewController = "SplitViewController"
        static let ordersHistoryViewController = "OrdersHistoryViewController"
        static let menuSplitViewController = "MenuSplitViewController"
    }
    
    struct Titles {
        static let inProcess = "En proceso"
        static let menu = "Menú"
        static let shoppingCar = "Carrito"
        static let more = "Más"
    }
    
    struct Collections {
        static let foodCollectionViewCell = "FoodCollectionViewCell"
        static let foodCell = "foodCell"
        static let extraIngredientCollectionViewCell = "ExtraIngredientCollectionViewCell"
        static let extraIngredientCell = "extraIngredientCell"
        static let itemTableViewCell = "ItemTableViewCell"
        static let itemCell = "itemCell"
        static let orderTableViewCell = "OrderTableViewCell"
        static let orderCell = "orderCell"
        static let notificationTableViewCell = "NotificationsTableViewCell"
        static let notificationCell = "notificationCell"
        
        static let customerCell = "customerCell"
    }
}
