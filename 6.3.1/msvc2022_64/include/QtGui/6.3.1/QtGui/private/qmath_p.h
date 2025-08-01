/****************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the QtGui module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2.0 or (at your option) the GNU General
** Public license version 3 or any later version approved by the KDE Free
** Qt Foundation. The licenses are as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-2.0.html and
** https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

#ifndef QMATH_P_H
#define QMATH_P_H

//
//  W A R N I N G
//  -------------
//
// This file is not part of the Qt API.  It exists purely as an
// implementation detail.  This header file may change from version to
// version without notice, or even be removed.
//
// We mean it.
//

#include <qmath.h>
#include <qtransform.h>

QT_BEGIN_NAMESPACE

static const qreal Q_PI   = qreal(M_PI);     // pi
static const qreal Q_MM_PER_INCH = 25.4;

inline QRect qt_mapFillRect(const QRectF &rect, const QTransform &xf)
{
    // Only for xf <= scaling or 90 degree rotations
    Q_ASSERT(xf.type() <= QTransform::TxScale
             || (xf.type() == QTransform::TxRotate && qFuzzyIsNull(xf.m11()) && qFuzzyIsNull(xf.m22())));
    // Transform the corners instead of the rect to avoid hitting numerical accuracy limit
    // when transforming topleft and size separately and adding afterwards,
    // as that can sometimes be slightly off around the .5 point, leading to wrong rounding
    QPoint pt1 = xf.map(rect.topLeft()).toPoint();
    QPoint pt2 = xf.map(rect.bottomRight()).toPoint();
    // Normalize and adjust for the QRect vs. QRectF bottomright
    return QRect::span(pt1, pt2).adjusted(0, 0, -1, -1);
}

QT_END_NAMESPACE

#endif // QMATH_P_H
