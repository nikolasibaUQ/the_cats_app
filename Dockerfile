FROM ghcr.io/cirruslabs/flutter:3.35.6 AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./

RUN flutter pub get --enforce-lockfile

COPY . .

RUN dart run build_runner build --delete-conflicting-outputs
RUN flutter gen-l10n

RUN flutter build web --release --dart-define-from-file=.env.example


FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
