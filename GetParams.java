class GetParams {
	public static void main(String[] args) {
		System.out.println("Title: " + args[0]);
		System.out.println("Description: " + args[1]);
		System.out.println("Number of assignments: " + args[2]);
		System.out.println("Reward: " + args[3]);
		System.out.println("Percentage failed to reject user: " + args[4]);

		// args[5] is a string containing all the tweet ids separated by commas
		String [] tweetIDs_string = args[5].split(",");
		int [] tweetIDs = new int[tweetIDs_string.length];
		System.out.print("Tweets selected: ");
		for (int id = 0; id < tweetIDs.length; id++) {
			tweetIDs[id] = Integer.parseInt(tweetIDs_string[id]);
			System.out.print(tweetIDs[id] + " ");
		}
	}
}
