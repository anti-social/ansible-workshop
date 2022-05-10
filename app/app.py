import os

from aiohttp import web


async def hello(request):
    print(os.environ)
    return web.Response(
        text=f"Hello, world from {os.environ.get('NAME', '???')}\n"
    )


def main():
    app = web.Application()
    app.add_routes([web.get('/', hello)])

    web.run_app(app)


if __name__ == '__main__':
    main()
