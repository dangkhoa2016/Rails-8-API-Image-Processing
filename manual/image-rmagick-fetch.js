
// 1 - login using admin credentials

fetch("/users/sign_in", {
  headers: {
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    "user": {
      "email": "admin@admin.admin",
      "password": "adminadmin"
    }
  }),
  method: "POST",
})


// responsed header
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

// 2 - process image

// {
//   "sharpen": [
//     0.1,
//     10
//   ]
// }
// get request
fetch("/image?url=https://[...].png&sharpen%5B%5D=0.1&sharpen%5B%5D=10", {
  headers: {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  method: "GET"
});

// post request
fetch("/image", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  body: JSON.stringify({
    "url": "https://[...].png",
    "sharpen": [
      0.1,
      10
    ]
  }),
  method: "POST"
});

// {
//   "sharpen": [
//     5,
//     10,
//   ]
// }
// get request
fetch("/image?url=https://[...].png&sharpen%5B%5D=5&sharpen%5B%5D=10", {
  headers: {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  method: "GET"
});


// post request
fetch("/image", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  body: JSON.stringify({
    "url": "https://[...].png",
    "sharpen": [
      5,
      10
    ]
  }),
  method: "POST"
});

// {
//   "resize": [
//     2
//   ]
// }
// get request
fetch("/image?url=https://[...].png&resize%5B%5D=2", {
  headers: {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  method: "GET"
});

// post request
fetch("/image", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  body: JSON.stringify({
    "url": "https://[...].png",
    "resize": [
      2
    ]
  }),
  method: "POST"
});

// {
//   "resize": [
//     0.3
//   ]
// }
// get request
fetch("/image?url=https://[...].png&resize%5B%5D=0.3", {
  headers: {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  method: "GET"
});

// post request
fetch("/image", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  body: JSON.stringify({
    "url": "https://[...].png",
    "resize": [
      0.3
    ]
  }),
  method: "POST"
});

// {
//   "format": "jpg",
//    "bg": "lime"
// }
// get request
fetch("/image?url=https://[...].png&format=jpg&bg=lime", {
  headers: {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  method: "GET"
});

// post request
fetch("/image", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  body: JSON.stringify({
    "url": "https://[...].png",
    "format": "jpg",
    "bg": "lime"
  }),
  method: "POST"
});


// {
//   "format": "jpg",
//   "q": 70,
//   "background": "orange"
// }
// get request
fetch("/image?url=https://[...].png&format=jpg&q=70&background=orange", {
  headers: {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  method: "GET"
});

// post request
fetch("/image", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  body: JSON.stringify({
    "url": "https://[...].png",
    "format": "jpg",
    "q": 70,
    "background": "orange"
  }),
  method: "POST"
});

// {
//   "resize": [
//     300,
//     300
//   ]
// }
// get request
fetch("/image?url=https://[...].png&resize%5B%5D=300&resize%5B%5D=300", {
  headers: {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  method: "GET"
});

// post request
fetch("/image", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  body: JSON.stringify({
    "url": "https://[...].png",
    "resize": [
      300,
      300
    ]
  }),
  method: "POST"
});


// {
//   "resize": [
//     300,
//     300
//   ],
//   "bg": "lime",
//   "f": "jpg"
// }
// get request
fetch("/image?url=https://[...].png&resize%5B%5D=300&resize%5B%5D=300&bg=lime&f=jpg", {
  headers: {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  method: "GET"
});

// post request
fetch("/image", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  body: JSON.stringify({
    "url": "https://[...].png",
    "resize": [
      300,
      300
    ],
    "bg": "lime",
    "f": "jpg"
  }),
  method: "POST"
});


// {
//   "resize": [
//     300,
//     300
//   ],
//   "rotate": [
//     90
//   ]
// }
// get request
fetch("/image?url=https://[...].png&resize%5B%5D=300&resize%5B%5D=300&rotate%5B%5D=90", {
  headers: {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  method: "GET"
});

// post request
fetch("/image", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  body: JSON.stringify({
    "url": "https://[...].png",
    "resize": [
      300,
      300
    ],
    "rotate": [
      90
    ]
  }),
  method: "POST"
});


// {
//   "resize": [
//     300,
//     300
//   ],
//   "rotate": [
//     120
//   ],
//   "bg": "lime",
//   "f": "jpg"
// }
// get request
fetch("/image?url=https://[...].png&resize%5B%5D=300&resize%5B%5D=300&rotate%5B%5D=120&bg=lime&f=jpg", {
  headers: {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  method: "GET"
});

// post request
fetch("/image", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  body: JSON.stringify({
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
  }),
  method: "POST"
});


// {
//   "resize": [
//     300,
//     300
//   ],
//   "rotate": [
//     120
//   ],
//   "bg": "lime",
//   "f": "jpg",
//   "q": 80
// }
// get request
fetch("/image?url=https://[...].png&resize%5B%5D=300&resize%5B%5D=300&rotate%5B%5D=120&bg=lime&f=jpg&q=80", {
  headers: {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  method: "GET"
});

// post request
fetch("/image", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  body: JSON.stringify({
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
  }),
  method: "POST"
});


// {
//   "resize": [
//     256,
//     512
//   ],
//   "f": "jpg",
//   "bg": "#fff"
// }
// get request
fetch("/image?url=https://[...].png&resize%5B%5D=256&resize%5B%5D=512&f=jpg&bg=%23fff", {
  headers: {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  method: "GET"
});

// post request
fetch("/image", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  body: JSON.stringify({
    "url": "https://[...].png",
    "resize": [
      256,
      512
    ],
    "f": "jpg",
    "bg": "#fff"
  }),
  method: "POST"
});


// {
//   "format": "jpg",
//   "resize_to_fill": [
//     300,
//     100
//   ]
// }
// get request
fetch("/image?url=https://[...].png&format=jpg&resize_to_fill%5B%5D=300&resize_to_fill%5B%5D=100", {
  headers: {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  method: "GET"
});

// post request
fetch("/image", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  body: JSON.stringify({
    "url": "https://[...].png",
    "format": "jpg",
    "resize_to_fill": [
      300,
      100
    ]
  }),
  method: "POST"
});


// {
//   "format": "jpg",
//   "resize_to_fit": [
//     300,
//     100
//   ]
// }
// get request
fetch("/image?url=https://[...].png&format=jpg&resize_to_fit%5B%5D=300&resize_to_fit%5B%5D=100", {
  headers: {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  method: "GET"
});

// post request
fetch("/image", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  body: JSON.stringify({
    "url": "https://[...].png",
    "format": "jpg",
    "resize_to_fit": [
      300,
      100
    ]
  }),
  method: "POST"
});


// {
//   "format": "jpg",
//   "resize": [
//     300,
//     100
//   ]
// }
// get request
fetch("/image?url=https://[...].png&format=jpg&resize%5B%5D=300&resize%5B%5D=100", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  method: "GET"
});

// post request
fetch("/image", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  body: JSON.stringify({
    "url": "https://[...].png",
    "format": "jpg",
    "resize": [
      300,
      100
    ]
  }),
  method: "POST"
});


// {
//   "resize": [
//     300,
//     300
//   ],
//   "bg": "#ee7c46",
//   "rotate": 120
// }
// get request
fetch("/image?url=https://[...].png&resize%5B%5D=300&resize%5B%5D=300&bg=%23ee7c46&rotate=120", {
  headers: {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  method: "GET"
});

// post request
fetch("/image", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  body: JSON.stringify({
    "url": "https://[...].png",
    "resize": [
      300,
      300
    ],
    "bg": "#ee7c46",
    "rotate": 120
  }),
  method: "POST"
});


// {
//   "resize": [
//     300,
//     300
//   ],
//   "bg": "#ee7c46",
//   "rotate": 120,
//   "f": "jpg"
// }
// get request
fetch("/image?url=https://[...].png&resize%5B%5D=300&resize%5B%5D=300&bg=%23ee7c46&rotate=120&f=jpg", {
  headers: {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  method: "GET"
});

// post request
fetch("/image", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  body: JSON.stringify({
    "url": "https://[...].png",
    "resize": [
      300,
      300
    ],
    "bg": "#ee7c46",
    "rotate": 120,
    "f": "jpg"
  }),
  method: "POST"
});


// {
//   "resize": [
//     300,
//     300
//   ],
//   "bg": "#ee7c46",
//   "rotate": [
//     120,
//     { "background": "lime" }
//   ],
//   "f": "jpg"
// }
// get request
fetch("/image?url=https://[...].png&resize%5B%5D=300&resize%5B%5D=300&bg=%23ee7c46&rotate%5B%5D=120&rotate%5B%5D%5Bbackground%5D=lime&f=jpg", {
  headers: {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  method: "GET"
});

// post request
fetch("/image", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  body: JSON.stringify({
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
  }),
  method: "POST"
});


// {
//   "resize": [
//     300,
//     300
//   ],
//   "bg": "#ee7c46",
//   "rotate": 120,
//   "opaque": [
//     "white",
//     "lime"
//   ]
// }
// get request
fetch("/image?url=https://[...].png&resize%5B%5D=300&resize%5B%5D=300&bg=%23ee7c46&rotate=120&opaque%5B%5D=white&opaque%5B%5D=lime", {
  headers: {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  method: "GET"
});

// post request
fetch("/image", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  body: JSON.stringify({
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
  }),
  method: "POST"
});


// {
//   "toFormat": "png",
//   "resize": {
//     "width": 300,
//     "height": 300
//   },
//   "rotate": 120,
//   "bg": "lime",
//   "q": 50
// }
// get request
fetch("/image?url=https://[...].png&toFormat=png&resize%5Bwidth%5D=300&resize%5Bheight%5D=300&rotate%5B%5D=120&bg=lime&q=50", {
  headers: {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  method: "GET"
});

// post request
fetch("/image", {
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs"
  },
  body: JSON.stringify({
    "url": "https://[...].png",
    "toFormat": "png",
    "resize": {
      "width": 300,
      "height": 300
    },
    "rotate": 120,
    "bg": "lime",
    "q": 50
  }),
  method: "POST"
});
