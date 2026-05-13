import AppKit
import SwiftUI

struct ContentView: View {
    @State private var text = Self.demoText
    @State private var metrics = EditorMetrics.empty

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SwiftUI macOS Editor")
                .font(.title2)
                .foregroundStyle(.black)

            PlainTextEditor(text: $text, metrics: $metrics)
                .frame(maxWidth: .infinity)
                .frame(height: 250)

            EditorInfoPanel(metrics: metrics)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(16)
        .frame(minWidth: 760, minHeight: 620)
        .background(Color(nsColor: EditorTheme.canvasColor))
        .preferredColorScheme(.light)
    }
}

private extension ContentView {
    static let demoText = """
    这是第 1 行。
    这是第 2 行。
    这是第 3 行。
    这是第 4 行。
    这是第 5 行。
    这是第 6 行。
    这是第 7 行。
    这是第 8 行。
    这是第 9 行。
    这是第 10 行。
    这是第 11 行。
    这是第 12 行。
    这是第 13 行。
    这是第 14 行。
    这是第 15 行。
    这是第 16 行。
    """
}

private struct EditorInfoPanel: View {
    let metrics: EditorMetrics

    var body: some View {
        GroupBox("Editor Realtime Info") {
            ScrollView {
                Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 10) {
                    InfoRow(label: "总行数", value: "\(metrics.totalLines)")
                    InfoRow(label: "可视行", value: metrics.visibleLineSummary)
                    InfoRow(label: "可视区上方", value: metrics.linesAboveSummary)
                    InfoRow(label: "可视区下方", value: metrics.linesBelowSummary)
                    InfoRow(label: "可垂直滚动", value: metrics.canScrollVertically ? "是" : "否")
                    InfoRow(label: "垂直滚动条已显示", value: metrics.verticalScrollerVisible ? "是" : "否")
                    InfoRow(label: "字体", value: metrics.fontSummary)
                    InfoRow(label: "textContainerInset", value: metrics.textContainerInsetSummary)
                    InfoRow(label: "lineFragmentPadding", value: metrics.lineFragmentPaddingSummary)
                    InfoRow(label: "scrollView contentInsets", value: metrics.scrollContentInsetSummary)
                    InfoRow(label: "viewport", value: metrics.viewportSummary)
                    InfoRow(label: "document", value: metrics.documentSummary)
                    InfoRow(label: "scroll offsetY", value: metrics.scrollOffsetSummary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        GridRow {
            Text(label)
                .font(.headline)
                .frame(width: 150, alignment: .leading)

            Text(value)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct EditorMetrics: Equatable {
    var totalLines: Int
    var visibleLineSpans: [LineSpan]
    var linesAboveVisible: [LineSpan]
    var linesBelowVisible: [LineSpan]
    var canScrollVertically: Bool
    var verticalScrollerVisible: Bool
    var fontName: String
    var fontPointSize: CGFloat
    var textContainerInset: CGSize
    var lineFragmentPadding: CGFloat
    var scrollContentInsets: NSEdgeInsets
    var viewportSize: CGSize
    var documentSize: CGSize
    var scrollOffsetY: CGFloat

    static let empty = EditorMetrics(
        totalLines: 1,
        visibleLineSpans: [LineSpan(start: 1, end: 1)],
        linesAboveVisible: [],
        linesBelowVisible: [],
        canScrollVertically: false,
        verticalScrollerVisible: false,
        fontName: "",
        fontPointSize: 0,
        textContainerInset: .zero,
        lineFragmentPadding: 0,
        scrollContentInsets: NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
        viewportSize: .zero,
        documentSize: .zero,
        scrollOffsetY: 0
    )

    static func == (lhs: EditorMetrics, rhs: EditorMetrics) -> Bool {
        lhs.totalLines == rhs.totalLines &&
        lhs.visibleLineSpans == rhs.visibleLineSpans &&
        lhs.linesAboveVisible == rhs.linesAboveVisible &&
        lhs.linesBelowVisible == rhs.linesBelowVisible &&
        lhs.canScrollVertically == rhs.canScrollVertically &&
        lhs.verticalScrollerVisible == rhs.verticalScrollerVisible &&
        lhs.fontName == rhs.fontName &&
        lhs.fontPointSize == rhs.fontPointSize &&
        lhs.textContainerInset == rhs.textContainerInset &&
        lhs.lineFragmentPadding == rhs.lineFragmentPadding &&
        lhs.scrollContentInsets.top == rhs.scrollContentInsets.top &&
        lhs.scrollContentInsets.left == rhs.scrollContentInsets.left &&
        lhs.scrollContentInsets.bottom == rhs.scrollContentInsets.bottom &&
        lhs.scrollContentInsets.right == rhs.scrollContentInsets.right &&
        lhs.viewportSize == rhs.viewportSize &&
        lhs.documentSize == rhs.documentSize &&
        lhs.scrollOffsetY == rhs.scrollOffsetY
    }
}

private extension EditorMetrics {
    var visibleLineSummary: String {
        "\(format(spans: visibleLineSpans))，共 \(visibleLineCount) 行"
    }

    var linesAboveSummary: String {
        format(spans: linesAboveVisible)
    }

    var linesBelowSummary: String {
        format(spans: linesBelowVisible)
    }

    var fontSummary: String {
        guard !fontName.isEmpty else {
            return "-"
        }

        return "\(fontName) \(format(number: fontPointSize))pt"
    }

    var textContainerInsetSummary: String {
        "w \(format(number: textContainerInset.width)), h \(format(number: textContainerInset.height))"
    }

    var lineFragmentPaddingSummary: String {
        format(number: lineFragmentPadding)
    }

    var scrollContentInsetSummary: String {
        "top \(format(number: scrollContentInsets.top)), left \(format(number: scrollContentInsets.left)), bottom \(format(number: scrollContentInsets.bottom)), right \(format(number: scrollContentInsets.right))"
    }

    var viewportSummary: String {
        "\(format(number: viewportSize.width)) x \(format(number: viewportSize.height))"
    }

    var documentSummary: String {
        "\(format(number: documentSize.width)) x \(format(number: documentSize.height))"
    }

    var scrollOffsetSummary: String {
        format(number: scrollOffsetY)
    }

    var visibleLineCount: Int {
        visibleLineSpans.reduce(0) { partialResult, span in
            partialResult + span.count
        }
    }

    private func format(spans: [LineSpan]) -> String {
        guard !spans.isEmpty else {
            return "无"
        }

        return spans.map(\.summary).joined(separator: ", ")
    }

    private func format(number: CGFloat) -> String {
        String(format: "%.1f", number)
    }
}

private struct LineSpan: Equatable {
    let start: Int
    let end: Int

    var count: Int {
        end - start + 1
    }

    var summary: String {
        if start == end {
            return "\(start)"
        }

        return "\(start)-\(end)"
    }
}

private enum EditorTheme {
    static let font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
    static let canvasColor = NSColor(calibratedWhite: 0.97, alpha: 1)
    static let editorBackgroundColor = NSColor(calibratedRed: 1, green: 0.97, blue: 0.78, alpha: 1)
    static let textColor = NSColor(calibratedWhite: 0.08, alpha: 1)
    static let selectionColor = NSColor(calibratedRed: 0.99, green: 0.86, blue: 0.45, alpha: 1)

    static var typingAttributes: [NSAttributedString.Key: Any] {
        [
            .font: font,
            .foregroundColor: textColor,
        ]
    }

    static func makeAttributedString(_ string: String) -> NSAttributedString {
        NSAttributedString(string: string, attributes: typingAttributes)
    }

    static func apply(to textView: NSTextView) {
        textView.appearance = NSAppearance(named: .aqua)
        textView.usesAdaptiveColorMappingForDarkAppearance = false
        textView.drawsBackground = true
        textView.backgroundColor = editorBackgroundColor
        textView.font = font
        textView.textColor = textColor
        textView.insertionPointColor = textColor
        textView.typingAttributes = typingAttributes
        textView.selectedTextAttributes = [
            .backgroundColor: selectionColor,
            .foregroundColor: textColor,
        ]
    }

    static func restyleTextStorage(of textView: NSTextView) {
        guard let textStorage = textView.textStorage else {
            return
        }

        let range = NSRange(location: 0, length: textStorage.length)
        guard range.length > 0 else {
            return
        }

        textStorage.setAttributes(typingAttributes, range: range)
    }
}

private struct PlainTextEditor: NSViewRepresentable {
    @Binding var text: String
    @Binding var metrics: EditorMetrics

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.borderType = .lineBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = true
        scrollView.backgroundColor = EditorTheme.editorBackgroundColor
        scrollView.appearance = NSAppearance(named: .aqua)

        let textView = ThemedTextView()
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.importsGraphics = false
        textView.allowsUndo = true
        textView.usesFindBar = true
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.autoresizingMask = [.width]
        textView.textContainerInset = NSSize(width: 12, height: 12)
        textView.textContainer?.lineFragmentPadding = 6
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.postsFrameChangedNotifications = true
        EditorTheme.apply(to: textView)
        textView.textStorage?.setAttributedString(EditorTheme.makeAttributedString(text))

        scrollView.contentView.postsBoundsChangedNotifications = true
        scrollView.contentView.postsFrameChangedNotifications = true
        scrollView.documentView = textView
        context.coordinator.attach(scrollView: scrollView, textView: textView)
        context.coordinator.scheduleMetricsUpdate()
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        context.coordinator.parent = self

        guard let textView = scrollView.documentView as? ThemedTextView else {
            return
        }

        EditorTheme.apply(to: textView)

        if textView.string != text {
            let selectedRange = textView.selectedRange()
            textView.textStorage?.setAttributedString(EditorTheme.makeAttributedString(text))
            textView.setSelectedRange(selectedRange)
        } else {
            EditorTheme.restyleTextStorage(of: textView)
        }

        context.coordinator.scheduleMetricsUpdate()
    }

    final class ThemedTextView: NSTextView {
        override func viewDidChangeEffectiveAppearance() {
            super.viewDidChangeEffectiveAppearance()
            EditorTheme.apply(to: self)
            EditorTheme.restyleTextStorage(of: self)
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: PlainTextEditor
        private weak var scrollView: NSScrollView?
        private weak var textView: NSTextView?
        private var observerTokens: [NSObjectProtocol] = []
        private var hasPendingMetricsUpdate = false

        init(parent: PlainTextEditor) {
            self.parent = parent
        }

        deinit {
            observerTokens.forEach(NotificationCenter.default.removeObserver)
        }

        func attach(scrollView: NSScrollView, textView: NSTextView) {
            self.scrollView = scrollView
            self.textView = textView
            observerTokens.forEach(NotificationCenter.default.removeObserver)
            observerTokens.removeAll()

            let notificationCenter = NotificationCenter.default
            observerTokens.append(
                notificationCenter.addObserver(
                    forName: NSView.boundsDidChangeNotification,
                    object: scrollView.contentView,
                    queue: .main
                ) { [weak self] _ in
                    self?.scheduleMetricsUpdate()
                }
            )
            observerTokens.append(
                notificationCenter.addObserver(
                    forName: NSView.frameDidChangeNotification,
                    object: scrollView.contentView,
                    queue: .main
                ) { [weak self] _ in
                    self?.scheduleMetricsUpdate()
                }
            )
            observerTokens.append(
                notificationCenter.addObserver(
                    forName: NSView.frameDidChangeNotification,
                    object: textView,
                    queue: .main
                ) { [weak self] _ in
                    self?.scheduleMetricsUpdate()
                }
            )
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }

            EditorTheme.apply(to: textView)
            EditorTheme.restyleTextStorage(of: textView)
            parent.text = textView.string
            scheduleMetricsUpdate()
        }

        func scheduleMetricsUpdate() {
            guard !hasPendingMetricsUpdate else {
                return
            }

            hasPendingMetricsUpdate = true
            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    return
                }

                self.hasPendingMetricsUpdate = false
                self.updateMetrics()
            }
        }

        private func updateMetrics() {
            guard
                let scrollView,
                let textView,
                let textContainer = textView.textContainer,
                let layoutManager = textView.layoutManager
            else {
                return
            }

            layoutManager.ensureLayout(for: textContainer)

            let documentVisibleRect = scrollView.contentView.documentVisibleRect
            let documentSize = textView.frame.size
            let viewportSize = scrollView.contentView.bounds.size
            let lineRanges = makeLineRanges(for: textView.string as NSString)
            let visibleLines = visibleLineNumbers(
                for: lineRanges,
                textView: textView,
                layoutManager: layoutManager,
                textContainer: textContainer,
                visibleRect: documentVisibleRect
            )
            let totalLines = lineRanges.count
            let firstVisible = visibleLines.first ?? 1
            let lastVisible = visibleLines.last ?? totalLines
            let canScrollVertically = documentSize.height > viewportSize.height + 1
            let verticalScrollerVisible = (scrollView.verticalScroller?.isHidden == false) && canScrollVertically
            let metrics = EditorMetrics(
                totalLines: totalLines,
                visibleLineSpans: makeLineSpans(from: visibleLines.isEmpty ? [1] : visibleLines),
                linesAboveVisible: firstVisible > 1 ? [LineSpan(start: 1, end: firstVisible - 1)] : [],
                linesBelowVisible: lastVisible < totalLines ? [LineSpan(start: lastVisible + 1, end: totalLines)] : [],
                canScrollVertically: canScrollVertically,
                verticalScrollerVisible: verticalScrollerVisible,
                fontName: textView.font?.fontName ?? "",
                fontPointSize: textView.font?.pointSize ?? 0,
                textContainerInset: textView.textContainerInset,
                lineFragmentPadding: textContainer.lineFragmentPadding,
                scrollContentInsets: scrollView.contentInsets,
                viewportSize: viewportSize,
                documentSize: documentSize,
                scrollOffsetY: documentVisibleRect.minY
            )

            if parent.metrics != metrics {
                parent.metrics = metrics
            }
        }

        private func makeLineRanges(for text: NSString) -> [NSRange] {
            guard text.length > 0 else {
                return [NSRange(location: 0, length: 0)]
            }

            var ranges: [NSRange] = []
            var location = 0

            while location < text.length {
                let lineRange = text.lineRange(for: NSRange(location: location, length: 0))
                ranges.append(lineRange)
                location = NSMaxRange(lineRange)
            }

            return ranges
        }

        private func visibleLineNumbers(
            for lineRanges: [NSRange],
            textView: NSTextView,
            layoutManager: NSLayoutManager,
            textContainer: NSTextContainer,
            visibleRect: NSRect
        ) -> [Int] {
            let textContainerOrigin = textView.textContainerOrigin
            return lineRanges.enumerated().compactMap { index, lineRange in
                let glyphRange = layoutManager.glyphRange(forCharacterRange: lineRange, actualCharacterRange: nil)
                let lineRect = layoutManager
                    .boundingRect(forGlyphRange: glyphRange, in: textContainer)
                    .offsetBy(dx: textContainerOrigin.x, dy: textContainerOrigin.y)

                guard !lineRect.isEmpty else {
                    return index == 0 ? index + 1 : nil
                }

                return lineRect.intersects(visibleRect) ? index + 1 : nil
            }
        }

        private func makeLineSpans(from lineNumbers: [Int]) -> [LineSpan] {
            guard let first = lineNumbers.first else {
                return []
            }

            var spans: [LineSpan] = []
            var start = first
            var previous = first

            for lineNumber in lineNumbers.dropFirst() {
                if lineNumber == previous + 1 {
                    previous = lineNumber
                    continue
                }

                spans.append(LineSpan(start: start, end: previous))
                start = lineNumber
                previous = lineNumber
            }

            spans.append(LineSpan(start: start, end: previous))
            return spans
        }
    }
}
