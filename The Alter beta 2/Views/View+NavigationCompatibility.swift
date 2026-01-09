import SwiftUI

extension View {
    @ViewBuilder
    func altarTitleInline() -> some View {
        #if os(iOS)
        if #available(iOS 16.0, *) {
            self.toolbarTitleDisplayMode(.inline)
        } else {
            self.navigationBarTitleDisplayMode(.inline)
        }
        #else
        if #available(macOS 13.0, *) {
            self.toolbarTitleDisplayMode(.inline)
        } else {
            self
        }
        #endif
    }

    @ViewBuilder
    func altarTitleLarge() -> some View {
        #if os(iOS)
        if #available(iOS 16.0, *) {
            self.toolbarTitleDisplayMode(.large)
        } else {
            self.navigationBarTitleDisplayMode(.large)
        }
        #else
        if #available(macOS 13.0, *) {
            self.toolbarTitleDisplayMode(.automatic)
        } else {
            self
        }
        #endif
    }

    @ViewBuilder
    func altarWheelPickerStyle() -> some View {
        #if os(iOS)
        self.pickerStyle(.wheel)
        #else
        self.pickerStyle(.automatic)
        #endif
    }
}

extension ToolbarItemPlacement {
    static var altarTrailing: ToolbarItemPlacement {
        #if os(iOS)
        if #available(iOS 16.0, *) {
            return .topBarTrailing
        } else {
            return .navigationBarTrailing
        }
        #else
        return .automatic
        #endif
    }

    static var altarLeading: ToolbarItemPlacement {
        #if os(iOS)
        if #available(iOS 16.0, *) {
            return .topBarLeading
        } else {
            return .navigationBarLeading
        }
        #else
        return .automatic
        #endif
    }
}

extension View {
    @ViewBuilder
    func altarWordsAutocapitalization() -> some View {
        #if os(iOS)
        self.textInputAutocapitalization(.words)
        #else
        self
        #endif
    }

    @ViewBuilder
    func altarNumberPadKeyboard() -> some View {
        #if os(iOS)
        self.keyboardType(.numberPad)
        #else
        self
        #endif
    }
}
