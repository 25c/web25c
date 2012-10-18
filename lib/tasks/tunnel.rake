namespace :tunnel do
  
  desc "Opens a reverse SSH tunnel for development"
  task :dev do
    processes = []
    puts "Opening http tunnel..."
    processes << open("|ssh -i ~/.ssh/25c.pem -nNT -R 80:127.0.0.1:3000 root@tunnel.plus25c.com")
    puts "Press ENTER to close all tunnels..."
    STDIN.gets
    puts "Closing tunnels..."
    processes.each do |process|
      puts "Sending INT to process id #{process.pid}..."
      Process.kill("INT", process.pid)
    end
    puts "Done."
  end
  
end
