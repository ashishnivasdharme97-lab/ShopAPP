# ShopAPI Udhar API

This .NET 8 Web API provides JWT-protected Udhar CRUD endpoints backed by
PostgreSQL. Admin tokens can list every record; non-admin tokens can access
records only when their numeric `userId`, `id`, or `sub` claim matches the
record's `UserId`.

## Configure and run

Set the PostgreSQL connection string and the JWT values. The JWT issuer,
audience, and signing key must match the token issuer used by the app. Keep the
signing key out of source control; it must be at least 32 bytes.

```powershell
$env:ConnectionStrings__DefaultConnection = "Host=localhost;Port=5432;Database=shop_api;Username=postgres;Password=YOUR_PASSWORD"
$env:Jwt__Issuer = "ShopAPI"
$env:Jwt__Audience = "ShopApp"
$env:Jwt__SigningKey = "use-a-private-random-secret-at-least-32-bytes"
dotnet tool restore
dotnet ef database update
dotnet run
```

Swagger is available at `http://localhost:5023/swagger` in Development. Use
the **Authorize** button with a valid bearer token.

## Routes

| Method | Route | Access |
|---|---|---|
| POST | `/api/udhar` | Authenticated; admins can assign any `UserId`, users can create only their own |
| GET | `/api/udhar` | Admin |
| GET | `/api/udhar/{id}` | Admin or record owner |
| GET | `/api/udhar/user/{userId}` | Admin or matching user |
| PUT | `/api/udhar/{id}` | Admin or record owner |
| DELETE | `/api/udhar/{id}` | Admin or record owner |

`UserId` is indexed but intentionally has no foreign key because this standalone
project does not include the existing application's user table. Add the
relationship when integrating this context into the app's existing database.

Validation errors return `400` ProblemDetails, missing/inaccessible records
return `404`, unauthenticated/unauthorized requests return `401`/`403`, create
returns `201`, updates return `200`, deletes return `204`, and unhandled server
errors return `500` ProblemDetails.

## Example request

```json
{
  "userId": 1,
  "customerName": "Rahul Patil",
  "amount": 1500.00,
  "remainingAmount": 1000.00,
  "dueDate": "2026-12-01T00:00:00Z",
  "notes": "Grocery bill",
  "isPaid": false,
  "paidAmount": 500.00
}
```

## Example response (`201 Created`)

```json
{
  "id": 1,
  "userId": 1,
  "customerName": "Rahul Patil",
  "amount": 1500.00,
  "remainingAmount": 1000.00,
  "dueDate": "2026-12-01T00:00:00Z",
  "notes": "Grocery bill",
  "isPaid": false,
  "paidAmount": 500.00,
  "createdAtUtc": "2026-11-12T15:00:00Z",
  "updatedAtUtc": null
}
```

## Flutter usage

The app's `UdharService` uses the existing `http` dependency and adds the
session token automatically. Open the example entry form from a screen that
knows the numeric `userId`:

```dart
final created = await Navigator.of(context).push<UdharModel>(
  MaterialPageRoute(
    builder: (_) => CreateUdharScreen(
      session: session,
      userId: userId,
    ),
  ),
);
```

Use `UdharService.getForUser`, `getById`, `update`, and `delete` for the
remaining operations. `getAll` is restricted to Admin tokens.
This standalone API uses port `5023` to avoid conflicting with the existing
Shop API on `5022`. For local Flutter testing, pass its base URL separately:

```powershell
flutter run --dart-define=UDHAR_API_BASE_URL=http://10.0.2.2:5023/api
```

For a physical device, use the development computer's LAN IP instead of
`10.0.2.2`. Configure the Udhar API's JWT issuer, audience, and signing key to
match the token issuer that the Flutter session uses.
