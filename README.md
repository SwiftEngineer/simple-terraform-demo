# simple-terraform-demo
Demo showing a simple example project using Terraform


### What it do

The `ui.tf` file describes s3 buckey with Static Website hosting enabled. It references this simple `code/index.html` file that makes a request to some static url I put in there. 

```html
<!doctype html>
<html>
  <head>
    <title>Music Genious</title>
  </head>
  <body class="container">
    <h1>Who is the voice of our generation?</h1>
    <h1 id="people" class="list-unstyled"></h1>
    <script src="https://unpkg.com/axios/dist/axios.min.js"></script>
    <script>
	<!-- You'll probably want to change this url if you are deploying this yourself: -->
      axios.get('https://terraform-goat-demo.doing.science/live/artists')
        .then(function (response) {
          document.getElementById('people').innerHTML = response.data.the_greatest_of_all_time;
        })
        .catch(function (err) {
          document.getElementById('people').innerHTML = err.message;
        });
    </script>
  </body>
</html>
```

The `api.tf` file describes a slightly more complex piece of infrastructure. It details out an API Gateway that uses lambda functions to handle incoming requests.

Finally, the `routing.tf` file is put in there to give a pretty name to the api url.