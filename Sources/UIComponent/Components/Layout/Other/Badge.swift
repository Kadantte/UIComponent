//  Created by y H on 2021/7/25.


import UIKit

/// Renders the child component with a badge (overlay) component on top.
/// The ``Badge`` component is similar to the ``Overlay`` component. The differences between ``Badge`` and ``Overlay`` are the following:
/// 1. `Badge` calculates the `badge` size based on its own content.
/// 2. `Badge` allows you to specify a `verticalAlignment` and a `horizontalAlignment` to control the `badge` position, similar to ``ZStack``.
/// 3. `Badge` allows you to specify an `offset` for the `badge` component.
///
/// Instead of using it directly, you can easily create a` Badge` component by using the ``Component/badge(verticalAlignment:horizontalAlignment:offset:_:)`` modifier.
/// ```swift
/// someComponent.badge(someOtherComponent, offset: CGPoint(x: 8, y: -8))
/// ```
/// or
/// ```swift
/// someComponent.badge(offset: CGPoint(x: 8, y: -8)) {
///   someOtherComponent
/// }
/// ```
///
/// Checkout the `ComplexLayoutViewController.swift` for other examples.
public struct Badge: Component {
    public enum Alignment: CaseIterable {
        case start, end, center, stretch, before, after
    }
    /// The primary component that will be rendered.
    public let child: any Component
    /// The component that will be rendered as an overlay on top of the `child`.
    public let overlay: any Component
    /// The vertical alignment for the `overlay` in relation to the `child`.
    public let verticalAlignment: Alignment
    /// The horizontal alignment for the `overlay` in relation to the `child`.
    public let horizontalAlignment: Alignment
    /// The offset point for the `overlay` component.
    public let offset: CGPoint

    /// Initializes a new badge with the specified components and alignments.
    /// - Parameters:
    ///   - child: The primary component that will be rendered.
    ///   - overlay: The component that will be rendered as an overlay on top of the `child`.
    ///   - verticalAlignment: The vertical alignment for the `overlay` in relation to the `child`.
    ///   - horizontalAlignment: The horizontal alignment for the `overlay` in relation to the `child`.
    ///   - offset: The offset point for the `overlay` component.
    public init(child: any Component, overlay: any Component, verticalAlignment: Alignment, horizontalAlignment: Alignment, offset: CGPoint) {
        self.child = child
        self.overlay = overlay
        self.verticalAlignment = verticalAlignment
        self.horizontalAlignment = horizontalAlignment
        self.offset = offset
    }

    public func layout(_ constraint: Constraint) -> some RenderNode {
        let childRenderNode = child.layout(constraint)
        let badgeRenderNode = overlay.layout(
            Constraint(
                minSize: CGSize(
                    width: horizontalAlignment == .stretch ? childRenderNode.size.width : -.infinity,
                    height: verticalAlignment == .stretch ? childRenderNode.size.height : -.infinity
                ),
                maxSize: CGSize(
                    width: horizontalAlignment == .stretch ? childRenderNode.size.width : .infinity,
                    height: verticalAlignment == .stretch ? childRenderNode.size.height : .infinity
                )
            )
        )
        let badgePosition: (x: CGFloat, y: CGFloat)
        switch horizontalAlignment {
        case .start:
            badgePosition.x = 0
        case .end:
            badgePosition.x = (childRenderNode.size.width - badgeRenderNode.size.width)
        case .center:
            badgePosition.x = (childRenderNode.size.width / 2 - badgeRenderNode.size.width / 2)
        case .stretch:
            badgePosition.x = 0
        case .before:
            badgePosition.x = -badgeRenderNode.size.width
        case .after:
            badgePosition.x = childRenderNode.size.width
        }
        switch verticalAlignment {
        case .start:
            badgePosition.y = 0
        case .end:
            badgePosition.y = (childRenderNode.size.height - badgeRenderNode.size.height)
        case .center:
            badgePosition.y = (childRenderNode.size.height / 2 - badgeRenderNode.size.height / 2)
        case .stretch:
            badgePosition.y = 0
        case .before:
            badgePosition.y = -badgeRenderNode.size.height
        case .after:
            badgePosition.y = childRenderNode.size.height
        }
        let finallyBadgePosition = CGPoint(x: badgePosition.x + offset.x, y: badgePosition.y + offset.y)

        return AlwaysRenderNode(size: childRenderNode.size, children: [childRenderNode, badgeRenderNode], positions: [.zero, finallyBadgePosition])
    }
}
