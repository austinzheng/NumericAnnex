//
//  Complex+Math.swift
//  NumericAnnex
//
//  Created by Xiaodi Wu on 4/2/17.
//

extension Complex /* : Numeric */ {
  @_transparent // @_inlineable
  public static func + (lhs: Complex, rhs: Complex) -> Complex {
    return Complex(
      real: lhs.real + rhs.real, imaginary: lhs.imaginary + rhs.imaginary
    )
  }

  @_transparent // @_inlineable
  public static func += (lhs: inout Complex, rhs: Complex) {
    lhs.real += rhs.real
    lhs.imaginary += rhs.imaginary
  }

  @_transparent // @_inlineable
  public static func - (lhs: Complex, rhs: Complex) -> Complex {
    return Complex(
      real: lhs.real - rhs.real, imaginary: lhs.imaginary - rhs.imaginary
    )
  }

  @_transparent // @_inlineable
  public static func -= (lhs: inout Complex, rhs: Complex) {
    lhs.real -= rhs.real
    lhs.imaginary -= rhs.imaginary
  }

  @_transparent // @_inlineable
  public static func * (lhs: Complex, rhs: Complex) -> Complex {
    return Complex(
      real: lhs.real * rhs.real - lhs.imaginary * rhs.imaginary,
      imaginary: lhs.real * rhs.imaginary + lhs.imaginary * rhs.real
    )
  }
}

extension Complex /* : SignedNumeric */ {
  @_transparent // @_inlineable
  public static prefix func - (operand: Complex) -> Complex {
    return Complex(real: -operand.real, imaginary: -operand.imaginary)
  }

  @_transparent // @_inlineable
  public mutating func negate() {
    real.negate()
    imaginary.negate()
  }
}

extension Complex : Math {
  @_transparent // @_inlineable
  public static func / (lhs: Complex, rhs: Complex) -> Complex {
    // Prevent avoidable overflow; see Numerical Recipes.
    if abs(rhs.real) >= abs(rhs.imaginary) {
      let ratio = rhs.imaginary / rhs.real
      let denominator = rhs.real + rhs.imaginary * ratio
      return Complex(
        real: (lhs.real + lhs.imaginary * ratio) / denominator,
        imaginary: (lhs.imaginary - lhs.real * ratio) / denominator
      )
    }
    let ratio = rhs.real / rhs.imaginary
    let denominator = rhs.real * ratio + rhs.imaginary
    return Complex(
      real: (lhs.real * ratio + lhs.imaginary) / denominator,
      imaginary: (lhs.imaginary * ratio - lhs.real) / denominator
    )

    /*
    let denominator = rhs.squaredMagnitude
    return Complex(
      real:
        (lhs.real * rhs.real + lhs.imaginary * rhs.imaginary) / denominator,
      imaginary:
        (lhs.imaginary * rhs.real - lhs.real * rhs.imaginary) / denominator
    )
    */
  }

  @_transparent // @_inlineable
  public func naturalExponential() -> Complex {
    return Complex(r: T.exp(real), theta: imaginary)
  }

  @_transparent // @_inlineable
  public func naturalLogarithm() -> Complex {
    return Complex(real: T.log(magnitude), imaginary: argument)
  }

  @_transparent // @_inlineable
  public func squareRoot() -> Complex {
    if imaginary.isInfinite {
      return Complex(real: .infinity, imaginary: imaginary)
    }
    if real.isInfinite {
      if real > 0 {
        return Complex(
          real: real,
          imaginary: imaginary.isNaN ? imaginary :
                                       T(signOf: imaginary, magnitudeOf: 0)
        )
      }
      return Complex(
        real: imaginary.isNaN ? imaginary : 0,
        imaginary: T(signOf: imaginary, magnitudeOf: real)
      )
    }
    // Guard intermediate results and enforce a branch cut; see Numerical
    // Recipes.
    if real == 0 && imaginary == 0 { return 0 }
    let w: T
    let x = abs(real), y = abs(imaginary)
    if x >= y {
      let r = y / x
      w = T.sqrt(x) * T.sqrt((1 + T.sqrt(1 + r * r)) / 2)
    } else {
      let r = x / y
      w = T.sqrt(y) * T.sqrt((r + T.sqrt(1 + r * r)) / 2)
    }
    if real >= 0 {
      return Complex(real: w, imaginary: imaginary / (2 * w))
    }
    /* real < 0 */
    return Complex(real: y / (2 * w), imaginary: imaginary >= 0 ? w : -w)

    /*
    return Complex(r: T.sqrt(magnitude), theta: argument / 2)
    */
  }

  @_transparent // @_inlineable
  public func cubeRoot() -> Complex {
    return Complex(r: T.cbrt(magnitude), theta: argument / 3)
  }

  @_transparent // @_inlineable
  public func power(of base: Complex) -> Complex {
    let mag = base.magnitude, arg = base.argument
    let r = T.pow(mag, real) * T.exp(-imaginary * arg)
    let theta = real * arg + imaginary * T.log(mag)
    return Complex(r: r, theta: theta)
  }

  @_transparent // @_inlineable
  public func sine() -> Complex {
    let sinh = Complex.sinh(Complex(real: -imaginary, imaginary: real))
    return Complex(real: sinh.imaginary, imaginary: -sinh.real)
    /*
    return Complex(
      real: T.sin(real) * T.cosh(imaginary),
      imaginary: T.cos(real) * T.sinh(imaginary)
    )
    */
  }

  @_transparent // @_inlineable
  public func cosine() -> Complex {
    return Complex.cosh(Complex(real: -imaginary, imaginary: real))
    /*
    return Complex(
      real: T.cos(real) * T.cosh(imaginary),
      imaginary: -T.sin(real) * T.sinh(imaginary)
    )
    */
  }

  @_transparent // @_inlineable
  public func tangent() -> Complex {
    let tanh = Complex.tanh(Complex(real: -imaginary, imaginary: real))
    return Complex(real: tanh.imaginary, imaginary: -tanh.real)
    /*
    // See AMS55 4.3.57
    let denominator = T.cos(2 * real) + T.cosh(2 * imaginary)
    return Complex(
      real: T.sin(2 * real) / denominator,
      imaginary: T.sinh(2 * imaginary) / denominator
    )
    */
  }

  @_transparent // @_inlineable
  public func arcsine() -> Complex {
    let asinh = Complex.asinh(Complex(real: -imaginary, imaginary: real))
    return Complex(real: asinh.imaginary, imaginary: -asinh.real)
    /*
    let temporary = Complex(real: 1 - (real * real - imaginary * imaginary))
    return -.i * Complex.log(.i * self + Complex.sqrt(temporary))
    */
  }

  @_transparent // @_inlineable
  public func arccosine() -> Complex {
    if real.isNaN {
      if imaginary.isInfinite {
        return Complex(real: real, imaginary: -imaginary)
      }
      return Complex(real: real, imaginary: real)
    }
    if real.isInfinite {
      if imaginary.isNaN {
        return Complex(real: imaginary, imaginary: real)
      }
      if imaginary.isInfinite {
        return Complex(
          real: real < 0 ? .pi * 3 / 4 : .pi / 4,
          imaginary: -imaginary
        )
      }
    }
    if real == 0 && (imaginary.isNaN || imaginary == 0) {
      return Complex(real: .pi / 2, imaginary: -imaginary)
    }
    if imaginary.isInfinite {
      return Complex(real: .pi / 2, imaginary: -imaginary)
    }
    let a = Complex(real: real * real - imaginary * imaginary - 1)
    let b = Complex.log(self + Complex.sqrt(a))
    return Complex(
      real: abs(b.imaginary),
      imaginary: imaginary.sign == .minus ? abs(b.real) : -abs(b.real)
    )
  }

  @_transparent // @_inlineable
  public func arctangent() -> Complex {
    let atanh = Complex.atanh(Complex(real: -imaginary, imaginary: real))
    return Complex(real: atanh.imaginary, imaginary: -atanh.real)
  }

  @_transparent // @_inlineable
  public func hyperbolicSine() -> Complex {
    if (real.isInfinite || real == 0) && !imaginary.isFinite {
      return Complex(real: real, imaginary: .nan)
    }
    if imaginary == 0 && !real.isFinite {
      return self
    }
    return Complex(
      real: T.sinh(real) * T.cos(imaginary),
      imaginary: T.cosh(real) * T.sin(imaginary)
    )
  }

  @_transparent // @_inlineable
  public func hyperbolicCosine() -> Complex {
    if real.isInfinite && !imaginary.isFinite {
      return Complex(real: abs(real), imaginary: .nan)
    }
    if real == 0 && imaginary == 0 {
      return Complex(real: 1, imaginary: imaginary)
    }
    if real == 0 && !imaginary.isFinite {
      return Complex(real: .nan, imaginary: real)
    }
    if imaginary == 0 && !real.isFinite {
      return Complex(real: abs(real), imaginary: imaginary)
    }
    return Complex(
      real: T.cosh(real) * T.cos(imaginary),
      imaginary: T.sinh(real) * T.sin(imaginary)
    )
  }

  @_transparent // @_inlineable
  public func hyperbolicTangent() -> Complex {
    if real.isInfinite {
      if !imaginary.isFinite { return 1 }
      return Complex(
        real: 1, imaginary: T(signOf: T.sin(2 * imaginary), magnitudeOf: 0)
      )
    }
    if real.isNaN && imaginary == 0 { return self }
    // See AMS55 4.5.51
    let twiceReal = 2 * real, twiceImaginary = 2 * imaginary
    let denominator = T.cosh(twiceReal) + T.cos(twiceImaginary)
    let sinh = T.sinh(twiceReal)
    if sinh.isInfinite && denominator.isInfinite {
      return Complex(
        real: sinh > 0 ? (1 as T) : -(1 as T),
        imaginary: twiceImaginary > 0 ? (0 as T) : -(0 as T)
      )
    }
    return Complex(
      real: sinh / denominator,
      imaginary: T.sin(twiceImaginary) / denominator
    )
  }

  @_transparent // @_inlineable
  public func inverseHyperbolicSine() -> Complex {
    if real.isNaN {
      if imaginary.isInfinite {
        return Complex(real: imaginary, imaginary: real)
      }
      if imaginary == 0 { return self }
      return Complex(real: real, imaginary: real)
    }
    if real.isInfinite {
      if imaginary.isNaN { return self }
      if imaginary.isInfinite {
        return Complex(
          real: real, imaginary: T(signOf: imaginary, magnitudeOf: .pi / 4)
        )
      }
      return Complex(
        real: real, imaginary: T(signOf: imaginary, magnitudeOf: 0)
      )
    }
    if imaginary.isInfinite {
      return Complex(
        real: T(signOf: real, magnitudeOf: imaginary),
        imaginary: T(signOf: imaginary, magnitudeOf: .pi / 2)
      )
    }
    let a = Complex(real: real * real - imaginary * imaginary + 1)
    let b = Complex.log(self + Complex.sqrt(a))
    return Complex(
      real: T(signOf: real, magnitudeOf: b.real),
      imaginary: T(signOf: imaginary, magnitudeOf: b.imaginary)
    )
  }

  @_transparent // @_inlineable
  public func inverseHyperbolicCosine() -> Complex {
    if real.isNaN {
      if imaginary.isInfinite {
        return Complex(real: .infinity, imaginary: real)
      }
      return Complex(real: real, imaginary: real)
    }
    if real.isInfinite {
      if imaginary.isNaN {
        return Complex(real: .infinity, imaginary: imaginary)
      }
      if imaginary.isInfinite {
        switch (real.sign, imaginary.sign) {
        case (.plus, .plus):
          return Complex(real: .infinity, imaginary: 1 / 4)
        case (.plus, .minus):
          return Complex(real: .infinity, imaginary: -1 / 4)
        case (.minus, .plus):
          return Complex(real: .infinity, imaginary: 3 / 4)
        case (.minus, .minus):
          return Complex(real: .infinity, imaginary: -3 / 4)
        }
      }
      switch (real.sign, imaginary.sign) {
      case (.plus, .plus):
        return Complex(real: .infinity, imaginary: 0)
      case (.plus, .minus):
        return Complex(real: .infinity, imaginary: -(0 as T))
      case (.minus, .plus):
        return Complex(real: .infinity, imaginary: .pi)
      case (.minus, .minus):
        return Complex(real: .infinity, imaginary: -.pi)
      }
    }
    if imaginary.isInfinite {
      return Complex(
        real: .infinity, imaginary: T(signOf: imaginary, magnitudeOf: .pi / 2)
      )
    }
    let a = Complex(real: real * real - imaginary * imaginary - 1)
    let b = Complex.log(self + Complex.sqrt(a))
    return Complex(
      real: T(signOf: 0, magnitudeOf: b.real),
      imaginary: T(signOf: imaginary, magnitudeOf: b.imaginary)
    )
  }

  @_transparent // @_inlineable
  public func inverseHyperbolicTangent() -> Complex {
    if imaginary.isNaN {
      if real.isInfinite || real == 0 {
        return Complex(
          real: T(signOf: real, magnitudeOf: 0), imaginary: imaginary
        )
      }
      return Complex(real: imaginary, imaginary: imaginary)
    }
    if imaginary.isInfinite {
      return Complex(
        real: T(signOf: real, magnitudeOf: 0),
        imaginary: T(signOf: imaginary, magnitudeOf: .pi / 2)
      )
    }
    if imaginary == 0 && abs(real) == 1 {
      return Complex(
        real: T(signOf: real, magnitudeOf: .infinity),
        imaginary: T(signOf: imaginary, magnitudeOf: 0)
      )
    }
    if real.isNaN {
      return Complex(real: real, imaginary: real)
    }
    if real.isInfinite {
      return Complex(
        real: T(signOf: real, magnitudeOf: 0),
        imaginary: T(signOf: imaginary, magnitudeOf: .pi / 2)
      )
    }
    let a = Complex.log((1 + self) / (1 - self)) / 2
    return Complex(
      real: T(signOf: real, magnitudeOf: a.real),
      imaginary: T(signOf: imaginary, magnitudeOf: a.imaginary)
    )
  }
}

/// Returns the square root of `z`.
@_transparent
public func sqrt<T>(_ z: Complex<T>) -> Complex<T> {
  return z.squareRoot()
}