# Playwrightメモ

## install

[公式 install手順](https://playwright.dev/docs/intro)

```shell
npm init playwright@latest

npx playwright test
# testが失敗して以下をインストールするように表示されたのでinstall
sudo npx playwright install-deps
```

---

## テストの生成

- スタートページを指定して実行する

```shell
npx playwright codegen localhost
```
> [!NOTE]
> 起動した状態ですでにrecordingは開始されているので操作を行うだけでテストが生成される。
> デフォルトではテストは保存されない
>
> ```shell
> npx playwright codegen localhost --output=basic_auth.ts
> ```

---

## テストの実行

[testMatch](https://playwright.dev/docs/api/class-testconfig#test-config-test-match)を使ってテストファイルかどうかを判別している。
デフォルトは.testもしくは.spec

> By default, Playwright looks for files matching the following glob pattern: **/*.@(spec|test).?(c|m)[jt]s?(x). This means JavaScript or TypeScript files with ".test" or ".spec" suffix, for example login-screen.wrong-credentials.spec.ts.

```shell
npx playwright test
```

```shell
npx playwright test --ui
```


