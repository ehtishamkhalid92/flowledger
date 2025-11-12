//
//  SimplePDFExporter.swift
//  FlowLedger
//
//  Created by Ehtisham Khalid on 12.11.2025.
//

import SwiftUI
import PDFKit

enum SimplePDFExporter {
    static func export(view: AnyView, fileName: String) throws -> URL {
        let pageSize = CGSize(width: 612, height: 792)
        let bounds = CGRect(origin: .zero, size: pageSize)
        let renderer = UIGraphicsPDFRenderer(bounds: bounds)

        // Render SwiftUI view
        let host = UIHostingController(rootView: view)
        host.view.bounds = bounds

        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            host.view.drawHierarchy(in: bounds, afterScreenUpdates: true)
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: url)
        try data.write(to: url, options: .atomic)
        return url
    }
}
