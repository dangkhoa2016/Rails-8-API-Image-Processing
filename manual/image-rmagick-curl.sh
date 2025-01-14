
# 1 - login using admin credentials
curl -X POST -H "Content-Type: application/json" \
  -d '{ "user": {
      "email":"admin@admin.admin","password":"adminadmin"
    }
  }' \
  http://localhost:4000/users/sign_in -v

# responsed header
"token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs",
{
  "id": 1,
  "email": "admin@localhost.test",
  "username": "admin",
  "first_name": "",
  "last_name": "",
  "avatar": null,
  "role": "admin",
  "confirmed_at": null,
  "created_at": "2025-01-27T11:18:24.422Z",
  "updated_at": "2025-01-28T09:59:51.845Z"
}

# 2 - process image

# {
#   "sharpen": [
#     0.1,
#     10
#   ]
# }
# get request
curl "http://localhost:4000/image?url=https://[...].png&sharpen%5B%5D=0.1&sharpen%5B%5D=10" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i

# post request
curl "http://localhost:4000/image" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://[...].png",
    "sharpen": [
      0.1,
      10
    ]
  }' -i


# {
#   "sharpen": [
#     5,
#     10
#   ]
# }
# get request
curl "http://localhost:4000/image?url=https://[...].png&sharpen%5B%5D=5&sharpen%5B%5D=10" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i

# post request
curl "http://localhost:4000/image" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://[...].png",
    "sharpen": [
      5,
      10
    ]
  }' -i


# {
#   "resize": [
#     2
#   ]
# }
# get request
curl "http://localhost:4000/image?url=https://[...].png&resize%5B%5D=2" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i

# post request
curl "http://localhost:4000/image" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://[...].png",
    "resize": [
      2
    ]
  }' -i


# {
#   "resize": [
#     0.3
#   ]
# }
# get request
curl "http://localhost:4000/image?url=https://[...].png&resize%5B%5D=0.3" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i

# post request
curl "http://localhost:4000/image" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://[...].png",
    "resize": [
      0.3
    ]
  }' -i


# {
#   "format": "jpg",
#    "bg": "lime"
# }
# get request
curl "http://localhost:4000/image?url=https://[...].png&format=jpg&bg=lime" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i


# post request
curl "http://localhost:4000/image" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://[...].png",
    "format": "jpg",
    "bg": "lime"
  }' -i


# {
#   "format": "jpg",
#   "q": 70,
#   "background": "orange"
# }
# get request
curl "http://localhost:4000/image?url=https://[...].png&format=jpg&q=70&background=orange" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i

# post request
curl "http://localhost:4000/image" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://[...].png",
    "format": "jpg",
    "q": 70,
    "background": "orange"
  }' -i


# {
#   "resize": [
#     300,
#     300
#   ]
# }
# get request
curl "http://localhost:4000/image?url=https://[...].png&resize%5B%5D=300&resize%5B%5D=300" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i

# post request
curl "http://localhost:4000/image" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://[...].png",
    "resize": [
      300,
      300
    ]
  }' -i


# {
#   "resize": [
#     300,
#     300
#   ],
#   "bg": "lime",
#   "f": "jpg"
# }
# get request
curl "http://localhost:4000/image?url=https://[...].png&resize%5B%5D=300&resize%5B%5D=300&bg=lime&f=jpg" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i

# post request
curl "http://localhost:4000/image" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://[...].png",
    "resize": [
      300,
      300
    ],
    "bg": "lime",
    "f": "jpg"
  }' -i


# {
#   "resize": [
#     300,
#     300
#   ],
#   "rotate": [
#     90
#   ]
# }
# get request
curl "http://localhost:4000/image?url=https://[...].png&resize%5B%5D=300&resize%5B%5D=300&rotate%5B%5D=90" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i

# post request
curl "http://localhost:4000/image" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://[...].png",
    "resize": [
      300,
      300
    ],
    "rotate": [
      90
    ]
  }' -i


# {
#   "resize": [
#     300,
#     300
#   ],
#   "rotate": [
#     120
#   ],
#   "bg": "lime",
#   "f": "jpg"
# }
# get request
curl "http://localhost:4000/image?url=https://[...].png&resize%5B%5D=300&resize%5B%5D=300&rotate%5B%5D=120&bg=lime&f=jpg" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i

# post request
curl "http://localhost:4000/image" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://[...].png",
    "resize": [
      300,
      300
    ],
    "rotate": [
      120
    ],
    "bg": "lime",
    "f": "jpg"
  }' -i


# {
#   "resize": [
#     300,
#     300
#   ],
#   "rotate": [
#     120
#   ],
#   "bg": "lime",
#   "f": "jpg",
#   "q": 80
# }
# get request
curl "http://localhost:4000/image?url=https://[...].png&resize%5B%5D=300&resize%5B%5D=300&rotate%5B%5D=120&bg=lime&f=jpg&q=80" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i

# post request
curl "http://localhost:4000/image" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://[...].png",
    "resize": [
      300,
      300
    ],
    "rotate": [
      120
    ],
    "bg": "lime",
    "f": "jpg",
    "q": 80
  }' -i


# {
#   "resize": [
#     256,
#     512
#   ],
#   "f": "jpg",
#   "bg": "#fff"
# }
# get request
curl "http://localhost:4000/image?url=https://[...].png&resize%5B%5D=256&resize%5B%5D=512&f=jpg&bg=%23fff" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i

# post request
curl "http://localhost:4000/image" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -d '{
    "url": "https://[...].png",
    "resize": [
      256,
      512
    ],
    "f": "jpg",
    "bg": "#fff"
  }' -i


# {
#   "format": "jpg",
#   "resize_to_fill": [
#     300,
#     100
#   ]
# }
# get request
curl "http://localhost:4000/image?url=https://[...].png&format=jpg&resize_to_fill%5B%5D=300&resize_to_fill%5B%5D=100" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i

# post request
curl "http://localhost:4000/image" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://[...].png",
    "format": "jpg",
    "resize_to_fill": [
      300,
      100
    ]
  }' -i


# {
#   "format": "jpg",
#   "resize_to_fit": [
#     300,
#     100
#   ]
# }
# get request
curl "http://localhost:4000/image?url=https://[...].png&format=jpg&resize_to_fit%5B%5D=300&resize_to_fit%5B%5D=100" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i

# post request
curl "http://localhost:4000/image" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://[...].png",
    "format": "jpg",
    "resize_to_fit": [
      300,
      100
    ]
  }' -i


# {
#   "format": "jpg",
#   "resize": [
#     300,
#     100
#   ]
# }
# get request
curl "http://localhost:4000/image?url=https://[...].png&format=jpg&resize%5B%5D=300&resize%5B%5D=100" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i

# post request
curl "http://localhost:4000/image" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://[...].png",
    "format": "jpg",
    "resize": [
      300,
      100
    ]
  }' -i


# {
#   "resize": [
#     300,
#     300
#   ],
#   "bg": "#ee7c46",
#   "rotate": 120
# }
# get request
curl "http://localhost:4000/image?url=https://[...].png&resize%5B%5D=300&resize%5B%5D=300&bg=%23ee7c46&rotate=120" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i

# post request
curl "http://localhost:4000/image" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://[...].png",
    "resize": [
      300,
      300
    ],
    "bg": "#ee7c46",
    "rotate": 120
  }' -i


# {
#   "resize": [
#     300,
#     300
#   ],
#   "bg": "#ee7c46",
#   "rotate": 120,
#   "f": "jpg"
# }
# get request
curl "http://localhost:4000/image?url=https://[...].png&resize%5B%5D=300&resize%5B%5D=300&bg=%23ee7c46&rotate=120&f=jpg" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i

# post request
curl "http://localhost:4000/image" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://[...].png",
    "resize": [
      300,
      300
    ],
    "bg": "#ee7c46",
    "rotate": 120,
    "f": "jpg"
  }' -i


# {
#   "resize": [
#     300,
#     300
#   ],
#   "bg": "#ee7c46",
#   "rotate": [
#     120,
#     { "background": "lime" }
#   ],
#   "f": "jpg"
# }
# get request
curl "http://localhost:4000/image?url=https://[...].png&resize%5B%5D=300&resize%5B%5D=300&bg=%23ee7c46&rotate%5B%5D=120&rotate%5B%5D%5Bbackground%5D=lime&f=jpg" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i

# post request
curl "http://localhost:4000/image" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://[...].png",
    "resize": [
      300,
      300
    ],
    "bg": "#ee7c46",
    "rotate": [
      120,
      { background: "lime" }
    ],
    f: "jpg"
  }' -i


# {
#   "resize": [
#     300,
#     300
#   ],
#   "bg": "#ee7c46",
#   "rotate": 120,
#   "opaque": [
#     "white",
#     "lime"
#   ]
# }
# get request
curl "http://localhost:4000/image?url=https://[...].png&resize%5B%5D=300&resize%5B%5D=300&bg=%23ee7c46&rotate=120&opaque%5B%5D=white&opaque%5B%5D=lime" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i

# post request
curl "http://localhost:4000/image" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://[...].png",
    "resize": [
      300,
      300
    ],
    "bg": "#ee7c46",
    "rotate": 120,
    "opaque": [
      "white",
      "lime"
    ]
  }' -i


# {
#   "toFormat": "png",
#   "resize": {
#     "width": 300,
#     "height": 300
#   },
#   "rotate": 120,
#   "bg": "lime",
#   "q": 50
# }
# get request
curl "http://localhost:4000/image?url=https://[...].png&toFormat=png&resize%5Bwidth%5D=300&resize%5Bheight%5D=300&rotate%5B%5D=120&bg=lime&q=50" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i

# post request
curl "http://localhost:4000/image" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://[...].png",
    "toFormat": "png",
    "resize": {
      "width": 300,
      "height": 300
    },
    "rotate": 120,
    "bg": "lime",
    "q": 50
  }' -i
