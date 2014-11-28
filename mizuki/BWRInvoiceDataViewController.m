//
//  BWRInvoiceDataViewController.m
//  mizuki
//
//  Created by Carolina Mora on 03/07/14.
//  Copyright (c) 2014 Efrén Aguilar. All rights reserved.
//

#import "BWRInvoiceDataViewController.h"
#import "BWRInvoiceHistoryViewController.h"
#import "BWRUserPreferences.h"
#import "BWRMessagesToUser.h"
#import "BWRRFCInfoController.h"
#import "AppDelegate.h"

@interface BWRInvoiceDataViewController () <NSFetchedResultsControllerDelegate, UITextFieldDelegate>
@property BOOL opcion;
@property BWRRFCInfo *updateRFC;
@property BOOL firstRFC;
@property NSArray *textFieldsArray;
@end

@implementation BWRInvoiceDataViewController

@synthesize opcion;
@synthesize updateRFC;
@synthesize tf_rfc;
@synthesize tf_nombre;
@synthesize tf_apaterno;
@synthesize tf_amaterno;
@synthesize tf_calle;
@synthesize tf_noint;
@synthesize tf_noext;
@synthesize tf_colonia;
@synthesize tf_delegacion;
@synthesize tf_estado;
@synthesize tf_ciudad;
@synthesize tf_localidad;
@synthesize tf_cp;
@synthesize lb_direccion;
@synthesize bt_save;
@synthesize firstRFC;
@synthesize textFieldsArray;

static UITextField *activeField;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Measures
    NSInteger screenWidth = self.view.frame.size.width;
    NSInteger height = 31;
    NSInteger padding = 20;
    NSInteger depth = -20;
    NSInteger longWidth;
    NSInteger shortWidth;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if (firstRFC) {
            longWidth = (self.view.frame.size.width / 2) - (2 * padding);
            shortWidth = (longWidth / 2) - (padding/2);
        }else{
            longWidth = 270;
            shortWidth = 120;
        }
        
    }else{
        longWidth = screenWidth-(2*padding);
        shortWidth = (longWidth/2)-(padding/2);
    }
    
    //Scroll view
    UIScrollView *scrollView=(UIScrollView *)self.view;
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
    scrollView=[[UIScrollView alloc] initWithFrame:fullScreenRect];
    scrollView.contentSize=CGSizeMake(320,800);
    
    //Get keyboard tool
    UIToolbar *toolbar = [self getUIToolBarToKeyboard:screenWidth];
    
    // Information
    for(UIView *viewElement in textFieldsArray){
        //When arrive to address
        if([viewElement isKindOfClass:[UILabel class]]){
            // If is firstRFC capture and the device is a iPad
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && firstRFC){
                depth = -20;
                padding += longWidth + (padding * 2);
            }
            viewElement.frame = CGRectMake(padding, depth+=40, longWidth, height);
        }
        //Textfield
        else{
            ((UITextField *)viewElement).inputAccessoryView = toolbar;
            
            //Specifict conditions
            NSInteger index = [textFieldsArray indexOfObject:viewElement];
            switch (index) {
                case 6: //Internal number
                    viewElement.frame = CGRectMake(padding, depth+=40, shortWidth, height);
                    break;
                
                case 7: //External number
                    viewElement.frame = CGRectMake(padding*2+shortWidth, depth, shortWidth, height);
                    break;
                    
                default: //Others
                    viewElement.frame = CGRectMake(padding, depth+=40, longWidth, height);
                    break;
            }
        }
        //Add view to scrollview
        [scrollView addSubview:viewElement];
    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && !firstRFC){
        UIButton *listoButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [listoButton setTitle:NSLocalizedString(@"Guardar",nil) forState:UIControlStateNormal];
        [listoButton addTarget:self action:@selector(saveInfoRFC) forControlEvents:UIControlEventTouchUpInside];
        listoButton.frame = CGRectMake(padding, depth+=40, longWidth, height);
        [scrollView addSubview:listoButton];
    }
    
    //Ready button
    self.navigationItem.rightBarButtonItem = bt_save;
    
    //SCROLL VIEW
    self.view=scrollView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

#pragma mark - Inicialitation
/** Alloc and init each view element.
 
 Adding the method asings delegate and border style (TextField)
 */
- (void)createInvoiceData
{
    //RFC
    tf_rfc = [[UITextField alloc] init];
    //Nombre
    tf_nombre = [[UITextField alloc] init];
    //Apellido paterno
    tf_apaterno = [[UITextField alloc] init];
    //Apellido materno
    tf_amaterno = [[UITextField alloc] init];
    //Direccion
    lb_direccion = [[UILabel alloc] init];
    //Calle
    tf_calle = [[UITextField alloc] init];
    //Numero interior
    tf_noint = [[UITextField alloc] init];
    //Numero exterior
    tf_noext = [[UITextField alloc] init];
    //Colonia
    tf_colonia = [[UITextField alloc] init];
    //Delegacion
    tf_delegacion = [[UITextField alloc] init];
    //Estado
    tf_estado = [[UITextField alloc] init];
    //Ciudad
    tf_ciudad = [[UITextField alloc] init];
    //Localidad
    tf_localidad = [[UITextField alloc] init];
    //Codigo Postal
    tf_cp = [[UITextField alloc] init];
    
    //Init Array
    textFieldsArray = [[NSArray alloc] initWithObjects:tf_rfc, tf_nombre, tf_apaterno, tf_amaterno, lb_direccion, tf_calle, tf_noint, tf_noext, tf_colonia, tf_delegacion, tf_estado, tf_ciudad, tf_localidad, tf_cp, nil];
    
    //Init view elements
    for(UIView *viewElement in textFieldsArray){
        //TextField
        if([viewElement isKindOfClass:[UITextField class]]){
            UITextField *textField = (UITextField *)viewElement;
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.delegate=self;
        //Label
        }else{
            UILabel *label = (UILabel *)viewElement;
            label.text = NSLocalizedString(@"Dirección", nil);
        }
    }
    
    //Ready button
    bt_save = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Guardar", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveInfoRFC)];
    
    self.view.backgroundColor = [UIColor whiteColor];
    tf_cp.delegate = self;
    
    [self setTitle:NSLocalizedString(@"Datos de facturación",nil)];
}



#pragma mark - init
/** Init the viewController with default values and firstRFC in YES.
 
 The firstRFC indicates that the rfc will be seved like default selected rfc in user preferens.
 
 @param title NSString with the view title.
 */
-(void)initWithFirstRFC:(NSString *)title
{
    firstRFC = YES;
    [self initWithDefault:title];
}

/** Init the viewController with default values.
 
 Put in each textField in placeholder feature the element name.
 
 @param title NSString with the view title.
 */
- (void)initWithDefault: (NSString *)title
{
    [self createInvoiceData];
    
    
    //Create new rfc in core data
    opcion = TRUE;
    
    //Title
    self.title = title;
    
    //RFC
    tf_rfc.placeholder = @"RFC";
    //Nombre
    tf_nombre.placeholder = NSLocalizedString(@"Nombre",nil);
    //Apellido paterno
    tf_apaterno.placeholder = NSLocalizedString(@"Apellido Paterno",nil);
    //Apellido materno
    tf_amaterno.placeholder = NSLocalizedString(@"Apellido Materno", nil);
    //Calle
    tf_calle.placeholder = NSLocalizedString(@"Calle",nil);
    //Numero interior
    tf_noint.placeholder = NSLocalizedString(@"No Interior",nil);
    //Numero exterior
    tf_noext.placeholder = NSLocalizedString(@"No Exterior",nil);
    //Colonia
    tf_colonia.placeholder = NSLocalizedString(@"Colonia",nil);
    //Delegacion
    tf_delegacion.placeholder = NSLocalizedString(@"Delegación",nil);
    //Estado
    tf_estado.placeholder = NSLocalizedString(@"Estado",nil);
    //Ciudad
    tf_ciudad.placeholder = NSLocalizedString(@"Ciudad",nil);
    //Localidad
    tf_localidad.placeholder = NSLocalizedString(@"Localidad",nil);
    //Codigo Postal
    tf_cp.placeholder = NSLocalizedString(@"C.P.",nil);
    
}

/** Init the viewController with rfcInfo values.
 
 Put in each textField in placeholder feature the rfcInfo value.
 
 @param rfcInfo BWRFCInfo to edit.
 @param title NSString with the view title.
 */
- (void)initWithBWRRFCInfo:(BWRRFCInfo *)rfcInfo title:(NSString *)title
{
    [self initWithDefault:title];
    
    //Don't create new object in core data
    opcion = FALSE;
    updateRFC = rfcInfo;
    
    //RFC
    tf_rfc.text = rfcInfo.rfc;
    //Nombre
    tf_nombre.text = rfcInfo.nombre;
    //Apellido paterno
    tf_apaterno.text = rfcInfo.apellidoPaterno;
    //Apellido materno
    tf_amaterno.text = rfcInfo.apellidoMaterno;
    //Calle
    tf_calle.text = rfcInfo.calle;
    //Numero interior
    tf_noint.text = rfcInfo.numInterior;
    //Numero exterior
    tf_noext.text = rfcInfo.numExterior;
    //Colonia
    tf_colonia.text = rfcInfo.colonia;
    //Delegacion
    tf_delegacion.text = rfcInfo.delegacion;
    //Estado
    tf_estado.text = rfcInfo.estado;
    //Ciudad
    tf_ciudad.text = rfcInfo.ciudad;
    //Localidad
    tf_localidad.text = rfcInfo.localidad;
    //Codigo Postal
    tf_cp.text = rfcInfo.codigoPostal;
    
}

#pragma mark - Navigation
/** Save the rfcInfo in core data.
 
 According to the option it inserts or updates the rfcInfo in core data and validate the action executed.
 
 @param rfcInfo BWRFCInfo to edit.
 @param title NSString with the view title.
 */
- (void)saveInfoRFC
{
    BWRRFCInfoController *rfcInfoController = [[BWRRFCInfoController alloc] init];
    [rfcInfoController createRFCwithData:tf_rfc.text name:tf_nombre.text fatherLastname:tf_apaterno.text motherLastname:tf_amaterno.text country:@"MEXICO" state:tf_estado.text delegation:tf_delegacion.text colony:tf_colonia.text street:tf_calle.text internalNum:tf_noint.text externalNum:tf_noext.text postCode:tf_cp.text city:tf_ciudad.text town:tf_localidad.text];
    
    if([rfcInfoController validateRFCData]){
        //If option is add
        if(opcion){
            if([rfcInfoController addRFCInfo]){
                [self goToMyAccount:rfcInfoController.rfc];
            }
        }
        //If option is update
        else{
            if([rfcInfoController updateRFCInfoWithRFC:updateRFC]){
                [self goToMyAccount:rfcInfoController.rfc];
            }
        }
    }
    
}
                 
#pragma mark - Navegation
- (void) goToMyAccount: (NSString *)rfc{
    if (![BWRUserPreferences getStringValueForKey:@"rfc"]) {
        [BWRUserPreferences setStringValue:rfc forKey:@"rfc"];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && !firstRFC){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self performSegueWithIdentifier:@"invoiceHistorySegue" sender:self];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - KeyboardToolBar
-(UIToolbar *)getUIToolBarToKeyboard: (CGFloat)width{
    
    UIToolbar *keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
    
    UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Siguiente",nil) style:UIBarButtonItemStylePlain target:self action:@selector(nextField)];
    UIBarButtonItem *previousBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Anterior",nil) style:UIBarButtonItemStylePlain target:self action:@selector(previousField)];
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard)];
    
    [keyboardToolBar setItems:[[NSArray alloc] initWithObjects:doneBarButton, extraSpace, previousBarButton, nextBarButton, nil]];
    
    return keyboardToolBar;
}

-(void)nextField{
    NSInteger index = [textFieldsArray indexOfObject:activeField];
    
    if(index < textFieldsArray.count-1){
        if(index==3){
            index++;
        }
        activeField = [textFieldsArray objectAtIndex:index+1];
    }
    
    [activeField becomeFirstResponder];
}

-(void)previousField{
    NSInteger index = [textFieldsArray indexOfObject:activeField];
    
    if(index > 0){
        if(index==5){
            index--;
        }
        activeField = [textFieldsArray objectAtIndex:index-1];
    }
    
    [activeField becomeFirstResponder];
}

-(void)resignKeyboard{
    [activeField resignFirstResponder];
}

@end
