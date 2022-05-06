import os

from aiohttp import web


async def hello(request):
    return web.Response(
        text=f"Hello, world from {os.environ.get('NAME', '???')}"
    )


def main():
    app = web.Application()
    app.add_routes([web.get('/', hello)])

    web.run_app(app)


if __name__ == '__main__':
    main()
