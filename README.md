# Muhammed Faisal V — Flutter Developer Portfolio

Flutter Web portfolio. Uses Provider, GoRouter and Clean Architecture, with a feature-based folder layout.

## Run

```bash
flutter pub get
flutter run -d chrome --dart-define=WEB3FORMS_ACCESS_KEY=your_key
```

## Contact form setup (required for message delivery)

The form sends messages through [Web3Forms](https://web3forms.com), which forwards them to your inbox.

1. Go to web3forms.com, enter `faizalfaizy648@gmail.com` and copy the access key it emails you.
2. Pass the key at build time: `--dart-define=WEB3FORMS_ACCESS_KEY=...`.
   The key is meant to be public, because it can only send to your own inbox.

If there's no key, the form never pretends to succeed. It shows an error and an
"Email me directly" link instead. The form reports success only when Web3Forms
confirms delivery (`{"success": true}`).

## Build & deploy

```bash
flutter build web --release --dart-define=WEB3FORMS_ACCESS_KEY=your_key
```

- **Firebase Hosting:** run `firebase deploy`. `firebase.json` serves `build/web`
  and rewrites every route to `index.html`.
- **Vercel:** run `vercel deploy build/web --prod`. `web/vercel.json` is copied
  into the build and adds the same rewrites.

The site uses clean URLs such as `/projects/ealzo` and `/?section=contact`, so
the host must rewrite unknown paths to `index.html`. Both configs above do this.

After you deploy, change `og:image`, `twitter:image` and (optionally) `og:url`
in `web/index.html` to absolute URLs on your domain. Social previews need
absolute URLs.

## Updating content

| What | Where |
|---|---|
| Name, email, phone, LinkedIn, **GitHub** | `lib/core/constants/app_info.dart`. GitHub links stay hidden while `gitHubUrl` is empty. |
| Projects | `lib/features/projects/data/projects_local_data_source.dart` |
| Experience | `lib/features/experience/data/experience_data.dart` |
| Skills | `lib/features/skills/data/skills_data.dart` |
| Resume PDF | `web/documents/Muhammed_Faisal_V_Resume.pdf` |
| Colors / spacing / durations | `lib/core/constants/` |

### Adding real project screenshots

The project cards and galleries currently show code-drawn mockups labelled
"Illustrative preview". To show real screenshots:

1. Export portrait phone screenshots (WebP preferred, about 1080×2340).
2. Put them in `assets/images/projects/<project-id>/`.
3. Register the folder in `pubspec.yaml` under `flutter: assets:`.
4. List the files in that project's `screenshots: [...]` in
   `projects_local_data_source.dart`.

When a project has screenshots, the "illustrative" labels disappear on their own.

### Brand assets

`flutter test tool/brand_assets_test.dart` regenerates the favicon, PWA icons and
`web/og-image.png`.

## Tests

```bash
flutter analyze
flutter test
```
