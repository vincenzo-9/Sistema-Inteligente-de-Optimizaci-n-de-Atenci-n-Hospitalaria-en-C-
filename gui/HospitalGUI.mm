#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#include "Paciente.h"

#include <algorithm>
#include <map>
#include <queue>
#include <sstream>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <vector>

namespace {
NSString* ns(const std::string& value) {
    return [NSString stringWithUTF8String:value.c_str()];
}

std::string cpp(NSString* value) {
    if (value == nil) {
        return "";
    }
    const char* utf8 = [value UTF8String];
    return utf8 == nullptr ? "" : std::string(utf8);
}

bool prioridadPaciente(const Paciente& a, const Paciente& b) {
    if (a.gravedad != b.gravedad) {
        return a.gravedad < b.gravedad;
    }
    return a.timestamp < b.timestamp;
}

std::string textoPaciente(const Paciente& p) {
    std::ostringstream out;
    out << "[" << nombreGravedad(p.gravedad) << "] "
        << p.nombre << " | DNI: " << p.dni
        << " | Edad: " << p.edad
        << " | Sintomas: " << p.sintomas;
    return out.str();
}

class HospitalGuiModel {
public:
    void registrarPaciente(Paciente paciente) {
        if (paciente.timestamp == 0) {
            paciente.timestamp = timestampActual();
        }

        cola_.push(paciente);
        pacientes_.push_back(paciente);
        historial_[paciente.dni].push_back(paciente);
    }

    Paciente atenderSiguiente() {
        if (cola_.empty()) {
            throw std::runtime_error("No hay pacientes en cola.");
        }
        Paciente siguiente = cola_.top();
        cola_.pop();
        return siguiente;
    }

    std::string asignarSiguiente() {
        if (medicos_.empty()) {
            throw std::runtime_error("No hay medicos registrados.");
        }

        Paciente paciente = atenderSiguiente();
        auto elegido = std::min_element(
            medicos_.begin(),
            medicos_.end(),
            [](const auto& a, const auto& b) { return a.second < b.second; });

        ++elegido->second;

        std::ostringstream out;
        out << paciente.nombre << " asignado a " << elegido->first << ".";
        return out.str();
    }

    void registrarMedico(const std::string& nombre) {
        medicos_.try_emplace(nombre, 0);
    }

    void cargarDemo() {
        if (demoCargada_) {
            throw std::runtime_error("Los datos de demostracion ya fueron cargados.");
        }

        const long long base = timestampActual();
        const std::vector<Paciente> demo = {
            {"Carlos Mendez", "70000001", 65, 1, "Dolor toracico severo", base + 1},
            {"Lucia Ramos", "70000002", 8, 2, "Fiebre alta persistente", base + 2},
            {"Pedro Salas", "70000003", 34, 4, "Resfrio comun", base + 3},
            {"Ana Villanueva", "70000004", 29, 3, "Dolor abdominal", base + 4},
            {"Rosa Paredes", "70000005", 72, 1, "Dificultad respiratoria", base + 5},
        };

        for (const Paciente& paciente : demo) {
            registrarPaciente(paciente);
        }

        demoCargada_ = true;
    }

    std::string colaTexto() const {
        std::priority_queue<Paciente> copia = cola_;
        std::ostringstream out;
        int posicion = 1;

        if (copia.empty()) {
            return "No hay pacientes en espera.";
        }

        while (!copia.empty()) {
            out << posicion++ << ". " << textoPaciente(copia.top()) << '\n';
            copia.pop();
        }

        return out.str();
    }

    std::string historialTexto(const std::string& dni) const {
        const auto it = historial_.find(dni);
        if (it == historial_.end()) {
            return "No se encontraron registros para DNI " + dni + ".";
        }

        std::ostringstream out;
        for (const Paciente& paciente : it->second) {
            out << textoPaciente(paciente) << '\n';
        }
        return out.str();
    }

    std::string ordenadosTexto() const {
        std::vector<Paciente> copia = pacientes_;
        std::stable_sort(copia.begin(), copia.end(), prioridadPaciente);

        if (copia.empty()) {
            return "No hay pacientes registrados.";
        }

        std::ostringstream out;
        for (const Paciente& paciente : copia) {
            out << textoPaciente(paciente) << '\n';
        }
        return out.str();
    }

    std::string estadisticasTexto() const {
        int totalHistorial = 0;
        for (const auto& item : historial_) {
            totalHistorial += static_cast<int>(item.second.size());
        }

        std::ostringstream out;
        out << "Pacientes registrados: " << pacientes_.size() << '\n'
            << "Pacientes en cola: " << cola_.size() << '\n'
            << "Pacientes con historial: " << historial_.size() << '\n'
            << "Atenciones guardadas: " << totalHistorial << '\n'
            << "Medicos registrados: " << medicos_.size() << "\n\n"
            << "Carga de medicos:\n";

        for (const auto& [medico, carga] : medicos_) {
            out << "- " << medico << ": " << carga << " paciente(s)\n";
        }

        return out.str();
    }

private:
    std::priority_queue<Paciente> cola_;
    std::vector<Paciente> pacientes_;
    std::unordered_map<std::string, std::vector<Paciente>> historial_;
    bool demoCargada_ = false;
    std::map<std::string, int> medicos_ = {
        {"Dr. Luis Rojas", 0},
        {"Dra. Ana Torres", 0},
        {"Dra. Maria Perez", 0},
    };
};

NSColor* rgb(CGFloat r, CGFloat g, CGFloat b) {
    return [NSColor colorWithCalibratedRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1.0];
}

NSTextField* textLabel(NSView* parent, NSString* text, NSRect frame, CGFloat size, NSColor* color, BOOL bold) {
    NSTextField* view = [[NSTextField alloc] initWithFrame:frame];
    [view setStringValue:text];
    [view setBezeled:NO];
    [view setDrawsBackground:NO];
    [view setEditable:NO];
    [view setSelectable:NO];
    [view setLineBreakMode:NSLineBreakByTruncatingTail];
    [view setTextColor:color];
    [[view cell] setFont:bold ? [NSFont boldSystemFontOfSize:size] : [NSFont systemFontOfSize:size]];
    [parent addSubview:view];
    return view;
}

NSTextField* label(NSView* parent, NSString* text, NSRect frame) {
    return textLabel(parent, text, frame, 12, rgb(38, 62, 90), YES);
}

NSView* card(NSView* parent, NSRect frame) {
    NSView* view = [[NSView alloc] initWithFrame:frame];
    [view setWantsLayer:YES];
    view.layer.backgroundColor = [[NSColor whiteColor] CGColor];
    view.layer.cornerRadius = 8;
    view.layer.borderColor = [rgb(210, 222, 238) CGColor];
    view.layer.borderWidth = 1;
    view.layer.shadowColor = [[NSColor blackColor] CGColor];
    view.layer.shadowOpacity = 0.06;
    view.layer.shadowRadius = 12;
    view.layer.shadowOffset = CGSizeMake(0, -3);
    [parent addSubview:view];
    return view;
}

void cardTitle(NSView* parent, NSString* title, NSString* subtitle, CGFloat y) {
    textLabel(parent, title, NSMakeRect(18, y, parent.frame.size.width - 36, 22), 15, rgb(13, 71, 161), YES);
    if (subtitle != nil) {
        textLabel(parent, subtitle, NSMakeRect(18, y - 20, parent.frame.size.width - 36, 18), 11, rgb(100, 116, 139), NO);
    }
}

NSTextField* input(NSView* parent, NSRect frame, NSString* placeholder) {
    NSTextField* view = [[NSTextField alloc] initWithFrame:frame];
    [view setPlaceholderString:placeholder];
    [view setBezeled:YES];
    [view setDrawsBackground:YES];
    [view setTextColor:rgb(15, 23, 42)];
    [view setFont:[NSFont systemFontOfSize:13]];
    [view setBackgroundColor:[NSColor whiteColor]];
    [view setFocusRingType:NSFocusRingTypeExterior];
    [parent addSubview:view];
    return view;
}

NSImage* symbol(NSString* name) {
    if (@available(macOS 11.0, *)) {
        return [NSImage imageWithSystemSymbolName:name accessibilityDescription:nil];
    }
    return nil;
}

void setButtonTitle(NSButton* button, NSString* title, NSColor* color) {
    NSDictionary* attrs = @{
        NSForegroundColorAttributeName: color,
        NSFontAttributeName: [NSFont boldSystemFontOfSize:12]
    };
    [button setAttributedTitle:[[NSAttributedString alloc] initWithString:title attributes:attrs]];
}

NSButton* actionButton(NSView* parent, NSString* title, NSString* iconName, NSRect frame, NSColor* color, id target, SEL action) {
    NSButton* view = [[NSButton alloc] initWithFrame:frame];
    [view setTitle:title];
    [view setTarget:target];
    [view setAction:action];
    [view setBordered:NO];
    [view setImage:symbol(iconName)];
    [view setImagePosition:NSImageLeft];
    [view setFont:[NSFont boldSystemFontOfSize:12]];
    [view setContentTintColor:[NSColor whiteColor]];
    setButtonTitle(view, title, [NSColor whiteColor]);
    [view setToolTip:title];
    [view setWantsLayer:YES];
    view.layer.backgroundColor = [color CGColor];
    view.layer.cornerRadius = 7;
    [parent addSubview:view];
    return view;
}

NSButton* quietButton(NSView* parent, NSString* title, NSString* iconName, NSRect frame, id target, SEL action) {
    NSButton* view = actionButton(parent, title, iconName, frame, rgb(238, 242, 247), target, action);
    [view setContentTintColor:rgb(15, 23, 42)];
    setButtonTitle(view, title, rgb(15, 23, 42));
    view.layer.borderColor = [rgb(203, 213, 225) CGColor];
    view.layer.borderWidth = 1;
    return view;
}

NSTextView* textPanel(NSView* parent, NSString* title, NSString* subtitle, NSRect frame) {
    NSView* panel = card(parent, frame);
    cardTitle(panel, title, subtitle, frame.size.height - 34);

    NSRect scrollFrame = NSMakeRect(18, 18, frame.size.width - 36, frame.size.height - 78);
    NSScrollView* scroll = [[NSScrollView alloc] initWithFrame:scrollFrame];
    [scroll setBorderType:NSNoBorder];
    [scroll setHasVerticalScroller:YES];
    [scroll setAutohidesScrollers:YES];
    [scroll setWantsLayer:YES];
    scroll.layer.backgroundColor = [rgb(248, 250, 252) CGColor];
    scroll.layer.cornerRadius = 7;
    scroll.layer.borderColor = [rgb(226, 232, 240) CGColor];
    scroll.layer.borderWidth = 1;

    NSTextView* view = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, scrollFrame.size.width, scrollFrame.size.height)];
    [view setEditable:NO];
    [view setFont:[NSFont monospacedSystemFontOfSize:12 weight:NSFontWeightRegular]];
    [view setTextColor:rgb(30, 41, 59)];
    [view setBackgroundColor:rgb(248, 250, 252)];
    [view setTextContainerInset:NSMakeSize(12, 10)];

    [scroll setDocumentView:view];
    [panel addSubview:scroll];
    return view;
}
}

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property(nonatomic, strong) NSWindow* window;
@property(nonatomic, strong) NSTextField* nombreField;
@property(nonatomic, strong) NSTextField* dniField;
@property(nonatomic, strong) NSTextField* edadField;
@property(nonatomic, strong) NSTextField* sintomasField;
@property(nonatomic, strong) NSPopUpButton* gravedadMenu;
@property(nonatomic, strong) NSTextField* buscarField;
@property(nonatomic, strong) NSTextView* colaView;
@property(nonatomic, strong) NSTextView* historialView;
@property(nonatomic, strong) NSTextView* statsView;
@property(nonatomic, strong) NSTextField* statusLabel;
@end

@implementation AppDelegate {
    HospitalGuiModel model_;
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
    (void)notification;
    [NSApp setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameAqua]];

    self.window = [[NSWindow alloc]
        initWithContentRect:NSMakeRect(0, 0, 1120, 760)
                  styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                            NSWindowStyleMaskMiniaturizable
                    backing:NSBackingStoreBuffered
                      defer:NO];
    [self.window setTitle:@"Sistema Hospitalario ADA"];
    [self.window center];

    NSView* content = [self.window contentView];
    [content setWantsLayer:YES];
    content.layer.backgroundColor = [rgb(241, 245, 249) CGColor];

    NSView* header = [[NSView alloc] initWithFrame:NSMakeRect(0, 672, 1120, 88)];
    [header setWantsLayer:YES];
    header.layer.backgroundColor = [rgb(13, 71, 161) CGColor];
    [content addSubview:header];

    NSView* headerLine = [[NSView alloc] initWithFrame:NSMakeRect(0, 672, 1120, 4)];
    [headerLine setWantsLayer:YES];
    headerLine.layer.backgroundColor = [rgb(0, 121, 107) CGColor];
    [content addSubview:headerLine];

    textLabel(header, @"Sistema Hospitalario ADA", NSMakeRect(28, 48, 540, 26), 22, [NSColor whiteColor], YES);
    textLabel(header, @"Priorizacion, historial y asignacion medica con algoritmos en C++",
              NSMakeRect(30, 24, 650, 18), 12, rgb(219, 234, 254), NO);

    NSView* badge = [[NSView alloc] initWithFrame:NSMakeRect(920, 24, 164, 38)];
    [badge setWantsLayer:YES];
    badge.layer.backgroundColor = [[NSColor colorWithCalibratedWhite:1.0 alpha:0.14] CGColor];
    badge.layer.cornerRadius = 8;
    badge.layer.borderColor = [[NSColor colorWithCalibratedWhite:1.0 alpha:0.25] CGColor];
    badge.layer.borderWidth = 1;
    [header addSubview:badge];
    textLabel(badge, @"C++17 + ADA", NSMakeRect(18, 11, 130, 18), 13, [NSColor whiteColor], YES);

    NSView* formCard = card(content, NSMakeRect(24, 498, 1072, 148));
    cardTitle(formCard, @"Registro de paciente", @"Complete los datos y seleccione la gravedad clinica.", 110);

    label(formCard, @"Nombre", NSMakeRect(18, 64, 120, 18));
    self.nombreField = input(formCard, NSMakeRect(18, 34, 230, 30), @"Nombre completo");

    label(formCard, @"DNI", NSMakeRect(264, 64, 80, 18));
    self.dniField = input(formCard, NSMakeRect(264, 34, 132, 30), @"DNI");

    label(formCard, @"Edad", NSMakeRect(412, 64, 80, 18));
    self.edadField = input(formCard, NSMakeRect(412, 34, 80, 30), @"0");

    label(formCard, @"Gravedad", NSMakeRect(508, 64, 100, 18));
    self.gravedadMenu = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(508, 34, 156, 30)];
    [self.gravedadMenu addItemsWithTitles:@[@"1 - Critico", @"2 - Urgente", @"3 - Moderado", @"4 - Leve"]];
    [formCard addSubview:self.gravedadMenu];

    label(formCard, @"Sintomas", NSMakeRect(680, 64, 120, 18));
    self.sintomasField = input(formCard, NSMakeRect(680, 34, 220, 30), @"Motivo de consulta");

    actionButton(formCard, @"Registrar", @"plus.circle.fill", NSMakeRect(920, 32, 132, 34), rgb(0, 121, 107), self, @selector(registrar:));

    NSView* actionCard = card(content, NSMakeRect(24, 404, 1072, 68));
    actionButton(actionCard, @"Cargar demo", @"tray.and.arrow.down.fill", NSMakeRect(18, 18, 136, 34), rgb(21, 101, 192), self, @selector(cargarDemo:));
    actionButton(actionCard, @"Atender", @"checkmark.circle.fill", NSMakeRect(166, 18, 112, 34), rgb(22, 101, 52), self, @selector(atender:));
    actionButton(actionCard, @"Asignar medico", @"person.badge.plus", NSMakeRect(290, 18, 150, 34), rgb(180, 83, 9), self, @selector(asignar:));
    quietButton(actionCard, @"Ordenar", @"arrow.up.arrow.down", NSMakeRect(452, 18, 112, 34), self, @selector(ordenar:));
    quietButton(actionCard, @"Estadisticas", @"chart.bar.fill", NSMakeRect(576, 18, 132, 34), self, @selector(estadisticas:));

    label(actionCard, @"Buscar DNI", NSMakeRect(740, 42, 90, 18));
    self.buscarField = input(actionCard, NSMakeRect(740, 14, 142, 30), @"DNI");
    actionButton(actionCard, @"Buscar", @"magnifyingglass", NSMakeRect(894, 14, 134, 34), rgb(13, 71, 161), self, @selector(buscar:));

    self.colaView = textPanel(content, @"Cola de prioridad", @"Emergencias primero, llegada como desempate.",
                              NSMakeRect(24, 166, 520, 210));
    self.historialView = textPanel(content, @"Historial y ordenamiento", @"Resultados de busqueda, atencion y lista ordenada.",
                                   NSMakeRect(568, 166, 528, 210));
    self.statsView = textPanel(content, @"Estadisticas", @"Resumen operativo y carga de medicos.",
                               NSMakeRect(24, 34, 1072, 106));

    self.statusLabel = textLabel(content, @"Listo.", NSMakeRect(30, 8, 1060, 18), 12, rgb(71, 85, 105), NO);
    [self refrescarPaneles];

    [self.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender {
    (void)sender;
    return YES;
}

- (void)mostrarEstado:(const std::string&)mensaje {
    [self.statusLabel setStringValue:ns(mensaje)];
}

- (void)mostrarAlerta:(NSString*)titulo mensaje:(NSString*)mensaje estilo:(NSAlertStyle)estilo {
    NSAlert* alert = [[NSAlert alloc] init];
    [alert setMessageText:titulo];
    [alert setInformativeText:mensaje];
    [alert setAlertStyle:estilo];
    [alert addButtonWithTitle:@"OK"];
    [alert beginSheetModalForWindow:self.window completionHandler:nil];
}

- (void)mostrarExito:(NSString*)titulo mensaje:(const std::string&)mensaje {
    [self mostrarAlerta:titulo mensaje:ns(mensaje) estilo:NSAlertStyleInformational];
}

- (void)mostrarError:(const std::string&)mensaje {
    [self mostrarEstado:mensaje];
    [self mostrarAlerta:@"Atencion" mensaje:ns(mensaje) estilo:NSAlertStyleWarning];
}

- (void)refrescarPaneles {
    [self.colaView setString:ns(model_.colaTexto())];
    [self.statsView setString:ns(model_.estadisticasTexto())];
}

- (void)registrar:(id)sender {
    (void)sender;
    try {
        const std::string nombre = cpp([self.nombreField stringValue]);
        const std::string dni = cpp([self.dniField stringValue]);
        const std::string sintomas = cpp([self.sintomasField stringValue]);
        const int edad = [[self.edadField stringValue] intValue];
        const int gravedad = static_cast<int>([self.gravedadMenu indexOfSelectedItem]) + 1;

        if (nombre.empty() || dni.empty() || sintomas.empty() || edad <= 0) {
            [self mostrarError:"Complete nombre, DNI, edad valida y sintomas."];
            return;
        }

        model_.registrarPaciente({nombre, dni, edad, gravedad, sintomas, 0});
        const std::string mensaje = "Paciente " + nombre + " registrado con prioridad " + nombreGravedad(gravedad) + ".";
        [self mostrarEstado:mensaje];
        [self mostrarExito:@"Paciente registrado" mensaje:mensaje];
        [self.nombreField setStringValue:@""];
        [self.dniField setStringValue:@""];
        [self.edadField setStringValue:@""];
        [self.sintomasField setStringValue:@""];
        [self refrescarPaneles];
    } catch (const std::exception& ex) {
        [self mostrarError:ex.what()];
    }
}

- (void)cargarDemo:(id)sender {
    (void)sender;
    try {
        model_.cargarDemo();
        [self mostrarEstado:"Datos de demostracion cargados."];
        [self mostrarExito:@"Demo cargada" mensaje:"Se agregaron 5 pacientes de prueba a la cola."];
        [self refrescarPaneles];
    } catch (const std::exception& ex) {
        [self mostrarError:ex.what()];
    }
}

- (void)atender:(id)sender {
    (void)sender;
    try {
        const Paciente paciente = model_.atenderSiguiente();
        const std::string detalle = textoPaciente(paciente);
        [self mostrarEstado:"Paciente atendido correctamente."];
        [self.historialView setString:ns("Paciente atendido:\n" + detalle)];
        [self mostrarExito:@"Paciente atendido" mensaje:detalle];
        [self refrescarPaneles];
    } catch (const std::exception& ex) {
        [self mostrarError:ex.what()];
    }
}

- (void)asignar:(id)sender {
    (void)sender;
    try {
        const std::string resultado = model_.asignarSiguiente();
        [self mostrarEstado:resultado];
        [self.historialView setString:ns("Asignacion realizada:\n" + resultado)];
        [self mostrarExito:@"Medico asignado" mensaje:resultado];
        [self refrescarPaneles];
    } catch (const std::exception& ex) {
        [self mostrarError:ex.what()];
    }
}

- (void)ordenar:(id)sender {
    (void)sender;
    [self.historialView setString:ns(model_.ordenadosTexto())];
    [self mostrarEstado:"Pacientes ordenados por prioridad."];
    [self mostrarExito:@"Ordenamiento completado" mensaje:"La lista fue ordenada por gravedad y tiempo de llegada."];
}

- (void)estadisticas:(id)sender {
    (void)sender;
    [self.statsView setString:ns(model_.estadisticasTexto())];
    [self mostrarEstado:"Estadisticas actualizadas."];
    [self mostrarExito:@"Estadisticas actualizadas" mensaje:"El resumen operativo fue recalculado correctamente."];
}

- (void)buscar:(id)sender {
    (void)sender;
    const std::string dni = cpp([self.buscarField stringValue]);
    if (dni.empty()) {
        [self mostrarError:"Ingrese un DNI para buscar."];
        return;
    }
    const std::string resultado = model_.historialTexto(dni);
    [self.historialView setString:ns(resultado)];
    [self mostrarEstado:"Busqueda completada."];
    [self mostrarExito:@"Busqueda completada" mensaje:resultado];
}
@end

int main(int argc, const char* argv[]) {
    (void)argc;
    (void)argv;

    @autoreleasepool {
        NSApplication* app = [NSApplication sharedApplication];
        AppDelegate* delegate = [[AppDelegate alloc] init];
        [app setDelegate:delegate];
        [app run];
    }

    return 0;
}
