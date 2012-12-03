/**
 * Copyright (c) 2012, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * Demonstrates how to use the <c:zipfile> component
 **/
public with sharing class ZipDemoController
{
	// Zip file paths
	public List<String> paths {get;set;}
	
	// Generated zip file data (see receiveZipFile)
	public transient String zipFileData {get;set;}
	
	private ApexPages.StandardController controller;
	
	public ZipDemoController(ApexPages.StandardController controller)
	{
		this.controller = controller;
		
		// Info message to ask the user to wait (no real time progress messages yet)
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 
			'Zip processing for the attacments has started please wait, you will be redirected to the resulting Document once this is completed.'));
				
		// Use Attachment names as zip entry path names for this example
		List<Attachment> attachments = [select Name from Attachment where ParentId =: controller.getId()];
		paths = new List<String>();
		for(Attachment attachment : attachments)
			paths.add(attachment.Name);			
	}
	
	public PageReference receiveZipFile()
	{
		// Receive the generated zip file and store it (in this case as a Document)
		ZipFile__c zipFile = [select Name from ZipFile__c where Id =: controller.getId()]; 
		Document document = new Document();
		document.Name = zipFile.Name;
		document.FolderId = UserInfo.getUserId();
		document.Body = EncodingUtil.base64Decode(zipFileData);
		insert document;
		return new PageReference('/'+document.Id);
	}
	
	@RemoteAction
	public static String getZipFileEntry(String path, String state)
	{
		// Retrieve or generate the Base64 encoded data for each file path to be added to the zip
		Attachment attachment = [select Name, Body from Attachment where ParentId =:state and Name =:path];
		return EncodingUtil.base64Encode(attachment.body);
	}	
}