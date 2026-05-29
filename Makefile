CXX := g++
CXXFLAGS := -std=c++17 -Wall -Wextra -pedantic -Iinclude
OBJCXX := clang++
OBJCXXFLAGS := -std=c++17 -Wall -Wextra -pedantic -fobjc-arc -Iinclude
TARGET := hospital
GUI_APP := build/HospitalGUI.app
GUI_BIN := $(GUI_APP)/Contents/MacOS/HospitalGUI
SOURCES := main.cpp \
	src/Algoritmos.cpp \
	src/Benchmark.cpp \
	src/GestorMedicos.cpp \
	src/HistorialMedico.cpp \
	src/Hospital.cpp

.PHONY: all run gui open-gui clean

all: $(TARGET)

$(TARGET): $(SOURCES)
	$(CXX) $(CXXFLAGS) $(SOURCES) -o $(TARGET)

run: $(TARGET)
	./$(TARGET)

gui: $(GUI_BIN)

$(GUI_BIN): gui/HospitalGUI.mm include/Paciente.h
	mkdir -p $(GUI_APP)/Contents/MacOS
	mkdir -p $(GUI_APP)/Contents/Resources
	printf '%s\n' '<?xml version="1.0" encoding="UTF-8"?>' \
	'<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' \
	'<plist version="1.0"><dict>' \
	'<key>CFBundleExecutable</key><string>HospitalGUI</string>' \
	'<key>CFBundleIdentifier</key><string>edu.ada.hospitalgui</string>' \
	'<key>CFBundleName</key><string>HospitalGUI</string>' \
	'<key>CFBundlePackageType</key><string>APPL</string>' \
	'<key>CFBundleVersion</key><string>1.0</string>' \
	'</dict></plist>' > $(GUI_APP)/Contents/Info.plist
	$(OBJCXX) $(OBJCXXFLAGS) gui/HospitalGUI.mm -framework Cocoa -o $(GUI_BIN)

open-gui: gui
	open $(GUI_APP)

clean:
	rm -f $(TARGET)
	rm -rf build/*
