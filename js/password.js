// 利用可能なすべての文字
const allReadableChars = '!"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~'
// 標準64字
const standard64Chars = '!#%+23456789:=?@ABCDEFGHJKLMNPRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
// 拡張88字
const larger88Chars = '!"#$%&\'()*+,-./23456789:;<=>?@ABCDEFGHJKLMNOPRSTUVWXYZ[\\]^_abcdefghijkmnopqrstuvwxyz{|}~'
// 条件を満たすために計算する回数の最大値　
const maxRepeat = 10000

// 使用する文字
const charList = Array.from(Array(allReadableChars.length).keys()).map(i => ({
  char: allReadableChars.slice(i, i + 1),
  active: true,
  use: false
}))

// リセット（ページロード時、リセットボタン時）
const reset = () => {
  document.getElementById('length').value = '8'
  document.getElementById('std64set').checked = true
  document.getElementById('useUpr').checked = true
  document.getElementById('useLwr').checked = true
  document.getElementById('useNum').checked = true
  document.getElementById('useSym').checked = true
  document.getElementById('useAll').checked = true
  document.getElementById('avoidSameChars').checked = true
  document.getElementById('avoidSimilarChars').checked = true
  document.getElementById('similarChars').value = 'Il10O8B3Egqvu!|[]{}'
  updateActiveChars()
}

// 利用可能な文字を設定する。
const updateActiveChars = () => {
  // 詳細設定の設定項目の表示／非表示を切り替える。
  const sections = document.getElementsByClassName('for-customset')
  for (var i = 0; i < sections.length; i++) {
    sections.item(i).style.display = document.getElementById('customset').checked
      ? 'block'
      : 'none'
  }

  // それぞれの文字の利用の可否を設定する。
  charList.forEach(c => {
    c.active = true

    // 標準64字の場合
    if (document.getElementById('std64set').checked) {
      if (!standard64Chars.includes(c.char)) {
        c.active = false
      }

    // 拡張88字の場合
    } else if (document.getElementById('lrg88set').checked) {
      if (!larger88Chars.includes(c.char)) {
        c.active = false
      }

    // 詳細設定の場合
    } else {

      // 大文字を使用しない場合
      if (!document.getElementById('useUpr').checked) {
        if (/[A-Z]/.test(c.char)) {
          c.active = false
        }
      }

      // 小文字を使用しない場合
      if (!document.getElementById('useLwr').checked) {
        if (/[a-z]/.test(c.char)) {
          c.active = false
        }
      }

      // 数字を使用しない場合
      if (!document.getElementById('useNum').checked) {
        if (/[0-9]/.test(c.char)) {
          c.active = false
        }
      }

      // 記号を使用しない場合
      if (!document.getElementById('useSym').checked) {
        if (/[^0-9A-Za-z]/.test(c.char)) {
          c.active = false
        }
      }

      // 類似する文字を使用しない場合
      if (document.getElementById('avoidSimilarChars').checked) {
        const similarChars = document.getElementById('similarChars').value
        if (similarChars.includes(c.char)) {
          c.active = false
        }
      }
    }

  })

  // パスワードを生成する。
  generate()
}

// パスワードを生成する。
function generate() {
  const length = Number(document.getElementById('length').value)
  const chars = charList.filter(c => c.active).map(c => c.char)

  // エラー表示をクリアする。
  document.getElementById('generation-error').innerText = ''

  // 条件を満たすために計算する回数の限界まで繰り返す。
  for (var i = 0; i < maxRepeat; ++i) {

    // 使用可能な文字が無い場合は処理できない。
    if (!chars.length) { break }

    // 指定された文字数のパスワードを生成する。
    const password = Array.from(Array(length).keys()).map(m => {
      const n = Math.floor(Math.random() * chars.length)
      return chars.slice(n, n + 1)
    }).join('')

    // 「すべての種類の文字を使用する」が指定されている場合、
    // 条件を満たしていなければやり直す。
    if (document.getElementById('useAll').checked) {
      // 詳細設定の場合
      if (document.getElementById('customset').checked) {
        if (document.getElementById('useUpr').checked && !(/[A-Z]/.test(password))) { continue }
        if (document.getElementById('useLwr').checked && !(/[a-z]/.test(password))) { continue }
        if (document.getElementById('useNum').checked && !(/[0-9]/.test(password))) { continue }
        if (document.getElementById('useSym').checked && !(/[^0-9A-Za-z]/.test(password))) { continue }
      // それ以外の場合
      } else {
        if (!(/[0-9]/.test(password))) { continue }
        if (!(/[A-Z]/.test(password))) { continue }
        if (!(/[a-z]/.test(password))) { continue }
        if (!(/[^0-9A-Za-z]/.test(password))) { continue }
      }
    }
    // 「同じ文字を繰り返して使用しない」が指定されている場合、
    // 条件を満たしていなければやり直す。
    if (document.getElementById('avoidSameChars').checked) {
      if (password.split('').some((c, i) => password.slice(i + 1).includes(c))) { continue }
    }

    // 条件を満たすパスワードを表示する。
    document.getElementById('password').value = password

    // 使用した文字を表示する。
    charList.forEach(c => {
      c.use = password.includes(c.char)
    })
    showChars()

    // 処理を終了する。
    return
  }

  // 条件を満たすパスワードが生成できなかった場合、
  // エラーを表示する。
  document.getElementById('generation-error').innerText = '条件を満たすパスワードが生成できませんでした。'

  // 使用した文字を表示する。
  showChars()
}

// 使用した文字を表示する。
const showChars = () => {
  document.getElementById('char-list').innerHTML = charList.map(
    c => `<span class="${(c.use && 'use') || (c.active && 'active')}">${c.char}</span>`
  ).join(' ')
}
