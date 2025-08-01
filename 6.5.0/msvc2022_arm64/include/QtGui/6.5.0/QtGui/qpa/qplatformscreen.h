// Copyright (C) 2016 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

#ifndef QPLATFORMSCREEN_H
#define QPLATFORMSCREEN_H

//
//  W A R N I N G
//  -------------
//
// This file is part of the QPA API and is not meant to be used
// in applications. Usage of this API may make your code
// source and binary incompatible with future versions of Qt.
//

#include <QtGui/qtguiglobal.h>
#include <QtCore/qmetatype.h>
#include <QtCore/qnamespace.h>
#include <QtCore/qcoreevent.h>
#include <QtCore/qvariant.h>
#include <QtCore/qrect.h>
#include <QtCore/qobject.h>

#include <QtGui/qcolorspace.h>
#include <QtGui/qcursor.h>
#include <QtGui/qimage.h>
#include <QtGui/qwindowdefs.h>
#include <qpa/qplatformpixmap.h>

QT_BEGIN_NAMESPACE


class QPlatformBackingStore;
class QPlatformScreenPrivate;
class QPlatformWindow;
class QPlatformCursor;
class QScreen;
class QSurfaceFormat;

typedef QPair<qreal, qreal> QDpi;


class Q_GUI_EXPORT QPlatformScreen
{
    Q_DECLARE_PRIVATE(QPlatformScreen)

public:
    Q_DISABLE_COPY_MOVE(QPlatformScreen)

    enum SubpixelAntialiasingType { // copied from qfontengine_p.h since we can't include private headers
        Subpixel_None,
        Subpixel_RGB,
        Subpixel_BGR,
        Subpixel_VRGB,
        Subpixel_VBGR
    };

    enum PowerState {
        PowerStateOn,
        PowerStateStandby,
        PowerStateSuspend,
        PowerStateOff
    };

    struct Mode {
        QSize size;
        qreal refreshRate;
    };

    QPlatformScreen();
    virtual ~QPlatformScreen();

    virtual bool isPlaceholder() const { return false; }

    virtual QPixmap grabWindow(WId window, int x, int y, int width, int height) const;

    virtual QRect geometry() const = 0;
    virtual QRect availableGeometry() const {return geometry();}

    virtual int depth() const = 0;
    virtual QImage::Format format() const = 0;
    virtual QColorSpace colorSpace() const { return QColorSpace::SRgb; }

    virtual QSizeF physicalSize() const;
    virtual QDpi logicalDpi() const;
    virtual QDpi logicalBaseDpi() const;
    virtual qreal devicePixelRatio() const;

    virtual qreal refreshRate() const;

    virtual Qt::ScreenOrientation nativeOrientation() const;
    virtual Qt::ScreenOrientation orientation() const;

    virtual QWindow *topLevelAt(const QPoint &point) const;
    QWindowList windows() const;

    virtual QList<QPlatformScreen *> virtualSiblings() const;
    const QPlatformScreen *screenForPosition(const QPoint &point) const;

    QScreen *screen() const;

    //jl: should this function be in QPlatformIntegration
    //jl: maybe screenForWindow is a better name?
    static QPlatformScreen *platformScreenForWindow(const QWindow *window);

    virtual QString name() const { return QString(); }

    virtual QString manufacturer() const;
    virtual QString model() const;
    virtual QString serialNumber() const;

    virtual QPlatformCursor *cursor() const;
    virtual SubpixelAntialiasingType subpixelAntialiasingTypeHint() const;

    virtual PowerState powerState() const;
    virtual void setPowerState(PowerState state);

    virtual QList<Mode> modes() const;

    virtual int currentMode() const;
    virtual int preferredMode() const;

    static int angleBetween(Qt::ScreenOrientation a, Qt::ScreenOrientation b);
    static QTransform transformBetween(Qt::ScreenOrientation a, Qt::ScreenOrientation b, const QRect &target);
    static QRect mapBetween(Qt::ScreenOrientation a, Qt::ScreenOrientation b, const QRect &rect);

    static QDpi overrideDpi(const QDpi &in);

protected:
    void resizeMaximizedWindows();

    QScopedPointer<QPlatformScreenPrivate> d_ptr;

private:
    friend class QScreenPrivate;
};

// Qt doesn't currently support running with no platform screen
// QPA plugins can use this class to create a fake screen
class Q_GUI_EXPORT QPlatformPlaceholderScreen : public QPlatformScreen {
public:
    // virtualSibling can be passed in to make the placeholder a sibling with other screens during
    // the transitioning phase when the real screen is about to be removed, or the first real screen
    // is about to be added. This is useful because Qt will currently recreate (but now show!)
    // windows when they are moved from one virtual desktop to another, so if the last monitor is
    // unplugged, then plugged in again, windows will be hidden unless the placeholder belongs to
    // the same virtual desktop as the other screens.
    QPlatformPlaceholderScreen(bool virtualSibling = true) : m_virtualSibling(virtualSibling) {}
    bool isPlaceholder() const override { return true; }
    QRect geometry() const override { return QRect(); }
    QRect availableGeometry() const override { return QRect(); }
    int depth() const override { return 32; }
    QImage::Format format() const override { return QImage::Format::Format_RGB32; }
    QList<QPlatformScreen *> virtualSiblings() const override;
private:
    bool m_virtualSibling = true;
};

QT_END_NAMESPACE

#endif // QPLATFORMSCREEN_H
