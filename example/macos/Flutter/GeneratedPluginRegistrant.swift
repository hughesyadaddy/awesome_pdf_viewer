//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import device_info_plus
import pdfx_plugin
import printing

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  DeviceInfoPlusMacosPlugin.register(with: registry.registrar(forPlugin: "DeviceInfoPlusMacosPlugin"))
  PdfxPlugin.register(with: registry.registrar(forPlugin: "PdfxPlugin"))
  PrintingPlugin.register(with: registry.registrar(forPlugin: "PrintingPlugin"))
}
