# Geowiki

A Rails 8.1.1 application with Ruby 3.4.7, Bootstrap 5.3.8, and PostgreSQL.

## Requirements

- Docker
- Docker Compose

## Getting Started

### Development

1. Build and start the containers:
```bash
docker-compose up --build
```

2. Set up the database (in a new terminal):
```bash
docker-compose exec web rails db:create db:migrate
```

3. Access the application at http://localhost:3000

### Running Commands

All Rails commands should be run through Docker:

```bash
# Run migrations
docker-compose exec web rails db:migrate

# Run console
docker-compose exec web rails console

# Run tests
docker-compose run --rm test

# Run a specific rake task
docker-compose exec web rails db:seed
```

### Testing

Run the test suite:
```bash
docker-compose run --rm test
```

## Docker Services

- **web**: Rails application server (port 3000)
- **db**: PostgreSQL database (port 5432)
- **test**: Test runner service

## Deployment

The application includes GitHub Actions workflow that automatically builds and pushes Docker images to GitHub Container Registry when you push a tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The Docker image will be available at `ghcr.io/<username>/pdxhackerspace-geowiki`.

## Authentication

The application supports authentication via OmniAuth with Authentik as the identity provider, plus an optional local admin login.

### Authentik Setup

To enable Authentik authentication, set the following environment variables:

- `AUTHENTIK_CLIENT_ID`: Your Authentik OAuth2 client ID
- `AUTHENTIK_CLIENT_SECRET`: Your Authentik OAuth2 client secret
- `AUTHENTIK_SITE`: Your Authentik instance URL (default: https://authentik.example.com)

The application requests the `admin` scope to receive the `is_admin` claim from Authentik. Make sure your Authentik application is configured to:
1. Request the `admin` scope
2. Return the `is_admin` claim in the userinfo response

### Local Admin Login

For development or emergency access, you can set up a local admin account via environment variables:

- `LOCAL_ADMIN_EMAIL`: Email address for local admin login
- `LOCAL_ADMIN_PASSWORD`: Password for local admin login

When these are set, users can log in with these credentials through the standard login form. The local admin account will be created automatically with admin privileges.

### User Roles

- **Users**: Regular authenticated users
- **Admins**: Users with `is_admin: true` (set via Authentik claim or local admin)

Use `current_user.admin?` in controllers to check for admin status, or `require_admin!` to restrict access to admin-only actions.

## Maps

Maps are the core feature of Geowiki. Each map represents a visual document (floor plan, diagram, etc.) with associated metadata.

### Map Features

- **Name**: Required identifier for the map
- **Image**: Uploaded image file (PNG, JPEG, GIF, or WebP, max 10MB)
- **Slack Channel**: Optional Slack channel for discussions about this map
- **Parent Map**: Optional parent for hierarchical organization
- **Maintainers**: Users who can edit the map

### Permissions

- **Admins**: Can edit any map
- **Maintainers**: Can edit maps they are assigned to maintain
- **All users**: Can view all maps and create new maps

### Hierarchical Maps

Maps can be organized in a tree structure using parent/child relationships. This is useful for:
- Building floor plans with room detail maps
- Area overviews with zoomed sections
- Any hierarchical document structure

## Resources

Resources represent items, equipment, or locations that can be placed on maps.

### Resource Features

- **Name**: Required identifier for the resource
- **Internal/External**: Whether the resource is inside the facility or external
- **Source URLs**: One or more URLs linking to documentation, manuals, or related information
- **Map Locations**: One or more positions on maps (map + x,y coordinates)
- **Geographic Coordinates**: Latitude/longitude for external resources only

### Resource Types

| Type | Description |
|------|-------------|
| Internal | Resources located within the facility (no geo coordinates) |
| External | External resources that may have latitude/longitude coordinates |

### Map Locations

Resources can be placed on multiple maps with specific x,y coordinates. This allows:
- Tracking equipment across multiple floor plans
- Showing the same resource in overview and detail maps
- Documenting resource positions for reference

### Permissions

- **Admins**: Can create, edit, and delete resources
- **All users**: Can view resources and create new resources

## Technology Stack

- Rails 8.1.1
- Ruby 3.4.7
- Bootstrap 5.3.8
- PostgreSQL
- Docker & Docker Compose
- OmniAuth with Authentik

